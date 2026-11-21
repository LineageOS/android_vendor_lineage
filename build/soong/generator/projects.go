// Copyright (C) 2026 The LineageOS Project
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package generator

import (
	"fmt"
	"path/filepath"
	"strings"

	"android/soong/android"
)

// projectProperties lets a module track whole projects, chosen by the device,
// in addition to the files named by dep_files.
type projectProperties struct {
	// Directory that dep_projects entries are relative to. Variable-expanded, and may
	// be absolute as long as it is inside the source tree. Defaults to the top of the
	// source tree. Like dep_projects, this is NOT relative to dep_root.
	Dep_projects_root *string

	// Projects whose files should also be used for timestamp dependency checking.
	// Paths are relative to dep_projects_root.
	//
	// Each entry is variable-expanded and then split on whitespace, so a single
	// entry such as "$(TARGET_KERNEL_SOURCE_STEM)" can name any number of projects
	// (or none). Unlike dep_files, a project that matches no files is an error, so a
	// mistyped path cannot silently stop being tracked.
	Dep_projects []string

	// Glob patterns, relative to each project, applied to every project named by
	// dep_projects. Required when dep_projects is set.
	Dep_project_files []string
}

// trackProjects adds the files of every project named by dep_projects as input
// dependencies. It returns false if an error has been reported.
func (g *Module) trackProjects(ctx android.ModuleContext) bool {
	props := &g.projectProps
	if len(props.Dep_projects) == 0 {
		return true
	}
	if len(props.Dep_project_files) == 0 {
		ctx.PropertyErrorf("dep_project_files", "must be set when dep_projects is set")
		return false
	}

	root, err := projectsRoot(lineageExpandVariables(ctx, String(props.Dep_projects_root)))
	if err != nil {
		ctx.PropertyErrorf("dep_projects_root", "%s", err.Error())
		return false
	}
	if filepath.IsAbs(root) {
		// Globs take paths relative to the top of the source tree.
		root = android.ToRelativeSourcePath(ctx, root)
		if ctx.Failed() {
			return false
		}
	}

	for _, entry := range props.Dep_projects {
		projects, err := splitProjects(lineageExpandVariables(ctx, entry))
		if err != nil {
			ctx.PropertyErrorf("dep_projects", "%s", err.Error())
			return false
		}
		for _, project := range projects {
			matched := 0
			for _, pattern := range props.Dep_project_files {
				pattern = lineageExpandVariables(ctx, pattern)
				n, ok := g.globInputs(ctx, filepath.Join(root, project, pattern))
				if !ok {
					return false
				}
				matched += n
			}
			if matched == 0 {
				ctx.PropertyErrorf("dep_projects",
					"project %q matches no tracked files; is the path correct?",
					filepath.Join(root, project))
				return false
			}
		}
	}

	// Projects may overlap, or be listed more than once.
	g.inputDeps = android.FirstUniquePaths(g.inputDeps)
	return true
}

// globInputs globs pattern, which is relative to the top of the source tree, and
// records every file found as an input dependency. It returns the number of files
// recorded, and false if the glob itself failed (an error has been reported).
func (g *Module) globInputs(ctx android.ModuleContext, pattern string) (int, bool) {
	paths, err := ctx.GlobWithDeps(pattern, nil)
	if err != nil {
		ctx.ModuleErrorf("unable to glob %s: %s", pattern, err.Error())
		return 0, false
	}
	n := 0
	for _, path := range paths {
		if strings.HasSuffix(path, "/") {
			// Glob results for directories are suffixed with "/"; skip them since
			// sbox can only copy files, not directories, into the sandbox.
			continue
		}
		g.inputDeps = append(g.inputDeps, android.PathForSourceRelaxed(ctx, path))
		n++
	}
	return n, true
}

// splitProjects turns the expanded value of a dep_projects entry into a clean,
// de-duplicated list of project paths relative to dep_projects_root.
//
// Anything that would make the glob escape the root, or silently track all of it,
// is rejected rather than "fixed up".
func splitProjects(value string) ([]string, error) {
	var projects []string
	seen := map[string]bool{}

	for _, field := range strings.Fields(value) {
		if strings.Contains(field, "$(") {
			// lineageExpandVariables leaves variables it does not know about
			// untouched. Exported variables are always set (possibly to an
			// empty string), so this means the variable is missing from
			// EXPORT_TO_SOONG.
			return nil, fmt.Errorf("unexpanded variable in %q; is it listed in EXPORT_TO_SOONG?", field)
		}

		project := filepath.Clean(field)
		if filepath.IsAbs(project) || project == "." || project == ".." ||
			strings.HasPrefix(project, "../") {
			return nil, fmt.Errorf("project %q must be a path inside the source tree", field)
		}

		if !seen[project] {
			seen[project] = true
			projects = append(projects, project)
		}
	}

	return projects, nil
}

// projectsRoot validates the expanded value of dep_projects_root. An empty value
// means the top of the source tree. An absolute path is returned as is; the caller
// is responsible for making it relative to the top of the source tree.
func projectsRoot(value string) (string, error) {
	value = strings.TrimSpace(value)
	if value == "" {
		return "", nil
	}
	if strings.Contains(value, "$(") {
		return "", fmt.Errorf("unexpanded variable in %q; is it listed in EXPORT_TO_SOONG?", value)
	}

	root := filepath.Clean(value)
	if root == ".." || strings.HasPrefix(root, "../") {
		return "", fmt.Errorf("root %q must be a path inside the source tree", value)
	}

	return root, nil
}
