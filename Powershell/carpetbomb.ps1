#region About
    # C A R P E T B O M B
    # CARPETBOMB removes user profiles
    
    # Requirements:
    # - delprof2 - https://helgeklein.com/free-tools/delprof2-user-profile-deletion-tool/
    #   (must be in same directory as script or available in the computers PATH)
#endregion

[System.Collections.ArrayList]$excluded_users = @("Administrator", "staff", "student", "srika")

Write-Host("The following users are excluded from deletion automatically:")
ForEach($exclude in $excluded_users){
    Write-Host("    - $($exclude)")
}
Write-Host("")

$user = "a"
while(![string]::IsNullOrEmpty($user)){
    $user = Read-Host("Type the name of a user to exclude from deletion")
    if(![string]::IsNullOrEmpty($user)){
        $excluded_users.Add($user)
    }n
}

Write-Host("")
Write-Host("The final list of user accounts to exclude is:")
ForEach($exclude in $excluded_users){
    Write-Host("    - $($exclude)")
}

$exclude_string=""
ForEach($user in $excluded_users){
    $exclude_string += "/ed:$user "
}

Write-Host("$exclude_string")