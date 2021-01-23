using namespace System
using namespace System.IO
using namespace System.Management.Automation

###
 # I'm pretty sure this combination of attribute and state variable isn't going to be very
 # flexible, but this is more of an experiment
 ##

# class NamedDirConfigTransformationAttribute : ArgumentTransformationAttribute
# {
#     [NamedDirs] $NamedDirsConfig

#     NamedDirConfigTransformationAttribute([NamedDirs] $Config): base()
#     {
#         $this.NamedDirsConfig = $Config
#     }

#     NamedDirConfigTransformationAttribute() : base()
#     {
#         $this.NamedDirsConfig = $Global:PSNamedDirs
#     }

#     [string] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData)
#     {
#         # If string
#         if ($inputData -is [string])
#         {
#             # return as-is:
#             return $this.NamedDirsConfig.parse($inputData)
#         }
#         # if FileSystemInfo extension
#         elseif ($inputData -is [FileSystemInfo])
#         {
#             # convert to secure string:
#             return $this.NamedDirsConfig.parse($inputData.FullName)
#         }

#         # anything else throws an exception:
#         throw [System.InvalidOperationException]::new('Unexpected error.')
#     }
# }
