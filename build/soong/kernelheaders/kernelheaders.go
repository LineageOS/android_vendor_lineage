// Copyright 2018 The LineageOS Project. All rights reserved.
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

package kernelheaders

import (
	"fmt"
	"path"

	"github.com/google/blueprint"

	"android/soong/android"
	"android/soong/shared"
	"path/filepath"
)

func init() {
	android.RegisterModuleType("genkernelheaders", genKernelHeadersFactory)
}

var (
	pctx = android.NewPackageContext("lineage/soong/kernelheaders")
)

func init() {
	pctx.HostBinToolVariable("sboxCmd", "sbox")
}

type SourceFileGenerator interface {
	GeneratedSourceFiles() android.Paths
	GeneratedHeaderDirs() android.Paths
}

type HostToolProvider interface {
	HostToolPath() android.OptionalPath
}

type generatorProperties struct {
	// Enable reading a file containing dependencies in gcc format after the command completes
	Depfile bool

	// List of directories to export generated headers from
	Export_include_dirs []string

	// list of input files
	Srcs []string
}

type generator struct {
	android.ModuleBase

	properties generatorProperties

	tasks taskFunc

	deps android.Paths
	rule blueprint.Rule

	exportedIncludeDirs android.Paths

	outputFiles android.Paths
}

type taskFunc func(ctx android.ModuleContext, srcFiles android.Paths) []generateTask

type generateTask struct {
	in  android.Paths
	out android.WritablePaths
}

func (g *generator) GeneratedSourceFiles() android.Paths {
	return g.outputFiles
}

func (g *generator) Srcs() android.Paths {
	return g.outputFiles
}

func (g *generator) GeneratedHeaderDirs() android.Paths {
	return g.exportedIncludeDirs
}

func (g *generator) DepsMutator(ctx android.BottomUpMutatorContext) {
}

func crossCompilePrefixFromArch(ctx android.ModuleContext, arch string) string {
	switch arch {
	case "arm64":
		return "aarch64-linux-androidkernel-"
	case "arm":
		return "arm-linux-androidkernel-"
	case "x86":
		return "x86_64-linux-androidkernel-"
	default:
		ctx.ModuleErrorf("invalid arch: %s", arch)
	}
	return ""
}

func (g *generator) GenerateAndroidBuildActions(ctx android.ModuleContext) {
	if len(g.properties.Export_include_dirs) > 0 {
		for _, dir := range g.properties.Export_include_dirs {
			g.exportedIncludeDirs = append(g.exportedIncludeDirs,
				android.PathForModuleGen(ctx, ctx.ModuleDir(), dir))
		}
	} else {
		g.exportedIncludeDirs = append(g.exportedIncludeDirs, android.PathForModuleGen(ctx, ""))
	}

	kernelSrc := ctx.DeviceConfig().DeviceKernelSource()
	targetArch := *ctx.AConfig().ProductVariables.DeviceArch
	crossCompilePrefix := crossCompilePrefixFromArch(ctx, targetArch)

	cmdString := fmt.Sprintf("make -C %s O=$(genDir) ARCH=%s CROSS_COMPILE=%s headers_install", kernelSrc, targetArch, crossCompilePrefix)

	rawCommand, err := android.Expand(cmdString, func(name string) (string, error) {
		switch name {
		case "in":
			return "${in}", nil
		case "out":
			return "__SBOX_OUT_FILES__", nil
		case "depfile":
			if !g.properties.Depfile {
				return "", fmt.Errorf("$(depfile) used without depfile property")
			}
			return "${depfile}", nil
		case "genDir":
			genPath := android.PathForModuleGen(ctx, "").String()
			var relativePath string
			var err error
			outputPath := android.PathForOutput(ctx).String()
			relativePath, err = filepath.Rel(outputPath, genPath)
			if err != nil {
				panic(err)
			}
			return path.Join("__SBOX_OUT_DIR__", relativePath), nil
		default:
			return "", fmt.Errorf("unknown variable '$(%s)'", name)
		}
	})

	if err != nil {
		ctx.PropertyErrorf("cmd", "%s", err.Error())
		return
	}

	// tell the sbox command which directory to use as its sandbox root
	buildDir := android.PathForOutput(ctx).String()
	sandboxPath := shared.TempDirForOutDir(buildDir)

	// recall that Sprintf replaces percent sign expressions, whereas dollar signs expressions remain as written,
	// to be replaced later by ninja_strings.go
	sandboxCommand := fmt.Sprintf("$sboxCmd --sandbox-path %s --output-root %s -c %q $out", sandboxPath, buildDir, rawCommand)

	ruleParams := blueprint.RuleParams{
		Command:     sandboxCommand,
		CommandDeps: []string{"$sboxCmd"},
	}
	var args []string
	if g.properties.Depfile {
		ruleParams.Deps = blueprint.DepsGCC
		args = append(args, "depfile")
	}
	g.rule = ctx.Rule(pctx, "generator", ruleParams, args...)

	srcFiles := ctx.ExpandSources(g.properties.Srcs, nil)
	for _, task := range g.tasks(ctx, srcFiles) {
		g.generateSourceFile(ctx, task)
	}
}

func (g *generator) generateSourceFile(ctx android.ModuleContext, task generateTask) {
	desc := "generate"
	if len(task.out) == 1 {
		desc += " " + task.out[0].Base()
	}

	params := android.ModuleBuildParams{
		Rule:        g.rule,
		Description: "generate",
		Outputs:     task.out,
		Inputs:      task.in,
		Implicits:   g.deps,
	}
	if g.properties.Depfile {
		depfile := android.GenPathWithExt(ctx, "", task.out[0], task.out[0].Ext()+".d")
		params.Depfile = depfile
	}
	ctx.ModuleBuild(pctx, params)

	for _, outputFile := range task.out {
		g.outputFiles = append(g.outputFiles, outputFile)
	}
}

func generatorFactory(tasks taskFunc, props ...interface{}) android.Module {
	module := &generator{
		tasks: tasks,
	}

	module.AddProperties(props...)
	module.AddProperties(&module.properties)

	android.InitAndroidModule(module)

	return module
}

func genKernelHeadersFactory() android.Module {
	properties := &genKernelHeadersProperties{}

	tasks := func(ctx android.ModuleContext, srcFiles android.Paths) []generateTask {
		outs := make(android.WritablePaths, len(properties.Out))
		for i, out := range properties.Out {
			outs[i] = android.PathForModuleGen(ctx, out)
		}

		return []generateTask{
			{
				in:  srcFiles,
				out: outs,
			},
		}
	}

	return generatorFactory(tasks, properties)
}

type genKernelHeadersProperties struct {
	// names of the output files that will be generated
	Out []string
}
