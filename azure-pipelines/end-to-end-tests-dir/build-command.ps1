. $PSScriptRoot/../end-to-end-tests-prelude.ps1

$CurrentTest = "Build Command"

$commonArgs += $("--host-triplet",$Triplet,"--overlay-ports=$PSScriptRoot/../e2e-ports")

# Test that the build command fails if dependencies are missing
$out = Run-VcpkgAndCaptureOutput -TestArgs ($commonArgs + @("build","vcpkg-hello-world-1"))
Throw-IfNotFailed
if ($out -notmatch "The build command requires all dependencies to be already installed\.")
{
    throw "Expected to fail due to missing dependencies"
}

# Install the dependencies of vcpkg-hello-world-1
Run-Vcpkg -TestArgs ($commonArgs + @("install","vcpkg-cmake","vcpkg-cmake-config"))
Throw-IfFailed

# Test that the build command works
Run-Vcpkg -TestArgs ($commonArgs + @("build","vcpkg-hello-world-1"))
Throw-IfFailed

# Regression test https://github.com/microsoft/vcpkg/issues/13933
Run-Vcpkg -TestArgs ($commonArgs + @("install","vcpkg-hello-world-1"))
Throw-IfFailed
$out = Run-VcpkgAndCaptureStdErr -TestArgs ($commonArgs + @("build","vcpkg-hello-world-1"))
Throw-IfNotFailed
if ($out -notmatch "is already installed; please remove")
{
    throw "Expected to fail due to already being installed"
}
