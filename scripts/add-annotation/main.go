package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"text/template"

	"github.com/blang/semver"
	apimanifests "github.com/operator-framework/api/pkg/manifests"
	apivalidation "github.com/operator-framework/api/pkg/validation"
	"github.com/operator-framework/api/pkg/validation/errors"
	log "github.com/sirupsen/logrus"
)

type BundleDir struct {
	Path  string
	Error string
}

type Output struct {
	Errors          []BundleDir
	RequiresUpdate  []BundleDir
	BundleUpdated   []BundleDir
	BundleUnload    []BundleDir
	BundlesMigrated []BundleDir
	CurrentPath     string
}

func main() {
	createOutput()
}

func createOutput() {
	currentPath, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}
	output := Output{CurrentPath: currentPath}
	output.checkCommunityOperatorBundles()
	output.checkIfWeCanLoadTheBundles()

	var stillRequiring []BundleDir
	for _, r := range output.RequiresUpdate {
		found := false
		for _, u := range output.BundleUpdated {
			if r.Path == u.Path {
				found = true
				break
			}
		}
		if !found {
			stillRequiring = append(stillRequiring, r)
		}
	}

	// Replace
	output.RequiresUpdate = stillRequiring

	output.sort()
	output.write()

}

func (o *Output) checkCommunityOperatorBundles() {
	pathToWalk := filepath.Join(o.CurrentPath, "operators")

	err := filepath.Walk(pathToWalk, func(path string, info os.FileInfo, err error) error {
		_, errVer := semver.ParseTolerant(info.Name())
		if pathToWalk != path && info != nil && info.IsDir() && info.Name() != "manifest" && info.Name() != "manifests" && info.Name() != "metadata" &&
			info.Name() != "metadata" && info.Name() != "tests" && info.Name() != "scorecard" && errVer == nil {
			// Load the bundle
			bundle, err := apimanifests.GetBundleFromDir(path)
			if err != nil {
				o.Errors = append(o.Errors,
					BundleDir{Path: strings.ReplaceAll(path, o.CurrentPath, ""), Error: fmt.Sprintf("Unable to load the bundle: %s", err.Error())})
				return nil
			}

			results := runValidator(bundle)
			found := false
			errorMsg := ""
			for _, v := range results {
				for _, e := range v.Warnings {
					if strings.Contains(e.Detail, "this bundle is using APIs which were deprecated and removed in v1.22") {
						o.RequiresUpdate = append(o.RequiresUpdate,
							BundleDir{Path: strings.ReplaceAll(path, o.CurrentPath, "")})
						found = true
						errorMsg = e.Detail
						break
					}
				}
			}

			if !found {
				o.BundlesMigrated = append(o.BundlesMigrated,
					BundleDir{Path: strings.ReplaceAll(path, o.CurrentPath, "")})
				return nil
			}

			csvFileName := ""
			_ = filepath.Walk(path, func(pathInside string, infoInside os.FileInfo, err2 error) error {
				if infoInside != nil && !infoInside.IsDir() && strings.HasSuffix(infoInside.Name(), "yaml") {
					jsonFile, err := os.Open(pathInside)
					if err != nil {
						return nil
					}
					defer jsonFile.Close()

					var byteValue []byte
					byteValue, err = ioutil.ReadAll(jsonFile)
					if err != nil {
						return nil
					}

					if strings.Contains(string(byteValue), "kind: ClusterServiceVersion") {
						csvFileName = pathInside
						return nil
					}
				}
				return nil
			})

			if len(csvFileName) == 0 {
				o.Errors = append(o.Errors,
					BundleDir{Path: strings.ReplaceAll(path, o.CurrentPath, ""), Error: fmt.Sprintf("Unable to find csv file: %s", bundle.Name)})
				return nil
			}

			err = InsertCode(csvFileName, "annotations:", fmt.Sprintf(fragment, errorMsg))
			if err != nil {
				o.Errors = append(o.Errors,
					BundleDir{Path: strings.ReplaceAll(path, o.CurrentPath, ""), Error: fmt.Sprintf("Unable to insert code: %s", bundle.Name)})
				return nil
			}

			o.BundleUpdated = append(o.BundleUpdated,
				BundleDir{Path: strings.ReplaceAll(path, o.CurrentPath, "")})

		}
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}
}

func (o *Output) checkIfWeCanLoadTheBundles() {
	pathToWalk := filepath.Join(o.CurrentPath, "operators")

	err := filepath.Walk(pathToWalk, func(path string, info os.FileInfo, err error) error {
		_, errVer := semver.ParseTolerant(info.Name())
		if pathToWalk != path && info != nil && info.IsDir() && info.Name() != "manifest" &&
			info.Name() != "metadata" && info.Name() != "tests" && info.Name() != "scorecard" && errVer == nil {
			// Load the bundle
			_, err := apimanifests.GetBundleFromDir(path)
			if err != nil {
				o.BundleUnload = append(o.BundleUnload,
					BundleDir{Path: strings.ReplaceAll(path, o.CurrentPath, ""), Error: fmt.Sprintf("Unable to load the bundle after the changes: %s", err.Error())})
				return nil
			}
			return nil
		}
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}
}

func (o *Output) sort() {
	sort.Slice(o.BundleUpdated[:], func(i, j int) bool {
		return o.BundleUpdated[i].Path < o.BundleUpdated[j].Path
	})

	sort.Slice(o.RequiresUpdate[:], func(i, j int) bool {
		return o.RequiresUpdate[i].Path < o.RequiresUpdate[j].Path
	})

	sort.Slice(o.BundlesMigrated[:], func(i, j int) bool {
		return o.BundlesMigrated[i].Path < o.BundlesMigrated[j].Path
	})

	sort.Slice(o.BundleUnload[:], func(i, j int) bool {
		return o.BundleUnload[i].Path < o.BundleUnload[j].Path
	})

	sort.Slice(o.Errors[:], func(i, j int) bool {
		return o.Errors[i].Path < o.Errors[j].Path
	})
}

func (o *Output) write() {
	f, err := os.Create(filepath.Join(o.CurrentPath, "scripts/add-annotation/output.yml"))
	if err != nil {
		log.Fatal(err)
	}

	defer f.Close()

	t := template.Must(template.ParseFiles(filepath.Join(o.CurrentPath, "scripts/add-annotation/template.go.tmpl")))
	err = t.Execute(f, o)
	if err != nil {
		panic(err)
	}
}

func runValidator(bundle *apimanifests.Bundle) []errors.ManifestResult {
	validators := apivalidation.DefaultBundleValidators
	validators = validators.WithValidators(apivalidation.AlphaDeprecatedAPIsValidator)

	objs := bundle.ObjectsToValidate()

	results := validators.Validate(objs...)
	nonEmptyResults := []errors.ManifestResult{}

	for _, result := range results {
		if result.HasError() || result.HasWarn() {
			nonEmptyResults = append(nonEmptyResults, result)
		}
	}

	return nonEmptyResults
}

// InsertCode searches target content in the file and insert `toInsert` after the target.
func InsertCode(filename, target, code string) error {
	contents, err := ioutil.ReadFile(filename)
	if err != nil {
		return err
	}
	idx := strings.Index(string(contents), target)
	out := string(contents[:idx+len(target)]) + code + string(contents[idx+len(target):])
	// false positive
	// nolint:gosec
	return ioutil.WriteFile(filename, []byte(out), 0644)
}

const fragment = `
    # Setting operatorhub.io/ui-metadata-max-k8s-version annotation automatically
    # The following is an informative annotation to let its users know that this distribution
    # uses removed APIs in 1.22 and will not work on K8S clusters 1.22+.
    # Following the findings for this distribution:
    # %s
    operatorhub.io/ui-metadata-max-k8s-version: 1.21`
