﻿#------------------------------------------------------------------------------------------------------------------#
#----------------------------------------Global Functions----------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------#
$path = Resolve-Path .
Include $path\psake\teamcity.ps1

function global:run_msbuild ($solutionPath, $configuration)
{
    try 
    {
        switch ($configuration)
        {
            "release" 
            { 
                exec { msbuild $solutionPath "/m" "/t:rebuild" "/p:Configuration=$configuration;DeployOnBuild=true;DeployTarget=Package" } 
            }
            
            default 
            { 
                exec { msbuild $solutionPath "/m" "/t:rebuild" "/p:Configuration=$configuration" } 
            }
        }
    }
    catch 
    {
        TeamCity-ReportBuildStatus "ERROR" "MSBuild Compiler Error - see build log for details"
    }
}

function global:move_package ($source_dir, $destination_dir)
{
    if (-not (Test-Path $destination_dir))
    {
        mkdir $destination_dir
    }
    
    if (Test-Path $source_dir)
    {
        try 
        {
            Copy-Item "$source_dir\*" $destination_dir -recurse
        } 
        catch 
        {
            TeamCity-ReportBuildStatus "ERROR" "Failed to move package $source_dir to $destination_dir.  $_"
        }
    } 
    else 
    {
        TeamCity-ReportBuildStatus "ERROR" "The GiveCRM deployment package has not been created."
    }
}

function global:clean_up_pdb_files($package_dir)
{
    $pdbDir = "$package_dir\bin\*"
    if (Test-Path $pdbDir)
    {
        try
        {
            Remove-Item "$pdbDir" -include "*.pdb"
        }
        catch
        {
            TeamCity-ReportBuildStatus "ERROR" "Failed cleaning up PDB files from $package_dir\bin. $_"
        }
    }
}

function global:clean_directory ($package_dir)
{
    if (Test-Path $package_dir) 
    {
        try 
        {
            Remove-Item "$package_dir\*" -recurse
        }
        catch
        {
            TeamCity-ReportBuildStatus "ERROR" "Failed to clean up $package_dir. $_"
        }
    }
}
