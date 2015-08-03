#
# Module manifest for module 'Quest.ActiveRoles.ADManagement'
#
# Generated by: Quest Software
#
# Generated on: 7/16/2015
#

@{

# Script module or binary module file associated with this manifest.
ModuleToProcess = '.\Quest.ActiveRoles.ArsPowerShellSnapIn.dll'

# Version number of this module.
ModuleVersion = '1.6.0'

# ID used to uniquely identify this module
GUID = 'd022fb87-9178-4129-ac8a-6b069fa803c8'

# Author of this module
Author = 'Quest Software'

# Company or vendor of this module
CompanyName = 'Quest Software'

# Copyright statement for this module
Copyright = '(c) 2015 Quest Software. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Quest ActiveRoles Management Module'

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'Amd64'

# Assemblies that must be loaded prior to importing this module
RequiredAssemblies = 'Interop.ActiveDs.dll', 'Interop.ArsAdsi.dll', 
               'Microsoft.Practices.ObjectBuilder2.dll', 
               'Microsoft.Practices.Unity.dll', 
               'Microsoft.Practices.Unity.Interception.dll', 
               'Microsoft.Practices.Unity.StaticFactory.dll', 'NLog.dll', 
               'Quest.ActiveRoles.ArsPowerShellSnapIn.DirectoryAccess.dll', 
               'Quest.ActiveRoles.ArsPowerShellSnapIn.Utility.dll', 
               'Quest.ActiveRolesServer.Common.dll', 
               'Quest.ActiveRolesServer.Common.Services.dll'

# Type files (.ps1xml) to be loaded when importing this module
TypesToProcess = 'Quest.ActiveRoles.ADManagement.Types.ps1xml'

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = 'Quest.ActiveRoles.ADManagement.Format.ps1xml'

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

}
