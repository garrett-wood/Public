#XKCD PASSWORD GENERATOR

#Load example dictionary file at import
. $PSScriptRoot\dictionary.ps1

<#
.SYNOPSIS
This function creates random passwords using user defined characteristics. It is inspired by the XKCD 936 comic and the password generator spawned from it, XKPasswd.

.DESCRIPTION
This function uses a dictionary array and the user's input to create a random memorable password. The included example dictionary can be found in the above dot sourced file, and should be named $ExampleDictionary. It can be used to generate passwords for a variety of purposes and can also be used in combination with other functions in order to use a single line password set command. This function can be used without parameters and will generate a password using 3 words between 4 and 8 characters each.

.PARAMETER WordCount
This parameter is used to set the number of words in the password generated. The full range is between 1 and 24 words. Caution is advised at any count higher than 10

.PARAMETER MinWordLength
This parameter is used to set the minimum individual word length used in the password. The full range is between 1 and 24 characters. Selecting 24 will include all words up to 31 characters (it's not many). Its recommended value is 4. If none is specified, the default value of 4 will be used.

.PARAMETER MaxWordLength
This parameter is used to set the maximum individual word length used in the password. The full range is between 1 and 24 characters. Selecting 24 will include all words up to 31 characters (it's not many). Its recommended value is 8. If none is specified, the default value of 8 will be used.

.PARAMETER Transformations
This parameter is used to select how the words should be transformed. It will only accept the following options:

- None = Apply no changes to the words, use them exactly as listed in the dictionary array
- alternatingWORDcase = Capitalize every even word
- CapitaliseFirstLetter = Capitalize the first letter of each word
- cAPITALIZEeVERYlETTERbUTfIRST = Capitalize every letter except for the first letter in each word
- lowercase = Force all the words to lowercase
- UPPERCASE = Force all the words to uppercase
- RandomCapitalise = Randomly capitalize each word or not

.PARAMETER Separator
This parameter is used to set an array of symbols to be used as a separator between sections and words. Set to an empty value or $null to not have a separator, or set to just one character to force a particular character.

This is the default separator alphabet:

! @ $ % ^ & * - _ + = : | ~ ? / . ;

.PARAMETER FrontPaddingDigits
This parameter is used to set how many digits are added to the beginning of the password. Set to 0 to not have any padding digits.

.PARAMETER EndPaddingDigits
This parameter is used to set how many digits are added to the end of the password. Set to 0 to not have any padding digits.

.PARAMETER FrontPaddingSymbols
This parameter is used to set how many symbols are added to the beginning of the password. Set to 0 to not have any padding symbols.

.PARAMETER EndPaddingSymbols
This parameter is used to set how many symbols are added to the end of the password. Set to 0 to not have any padding symbols.

.PARAMETER PaddingSymbols
This parameter is used to set an array of symbols to be used to pad the beggining and end of the password. Set to an empty value or $null to not have any padding, or set to just one character to force a particular character.

This is the default padding alphabet:

! @ $ % ^ & * - _ + = : | ~ ? / . ;

.PARAMETER Dictionary
This parameter is used to define an array of strings that will be used to select the words in the password. It defaults to the $ExampleDictionary array from the dot sourced Dictionary.ps1 file

.EXAMPLE
New-SecurePassword

&&63&mohel&coopers&hibbin&65&&

Just running the command will generate a password with the default settings.

.EXAMPLE
New-SecurePassword -WordCount 3 -MinWordLength 4 -MaxWordLength 4 -Transformations RandomCapitalise -Separator @("-","+","=",".","*","_","|","~",",") -FrontPaddingDigits 0 -EndPaddingDigits 0 -FrontPaddingSymbols 1 -EndPaddingSymbols 1 -Verbose

VERBOSE: Dictionary contains 370222 words.
VERBOSE: 7197 potential words selected.
VERBOSE: Structure: [P][Word][S][Word][S][Word][P]
VERBOSE: Length: always 16 characters
.nies-haen-than.

This example will generate a password using the WEB16 settings from xkpasswd.net with verbosity enabled.

.NOTES
RELATED LINKS
XKCD Comic 936: https://xkcd.com/936/
XKPasswd:       https://xkpasswd.net/
Original:       https://github.com/garrett-wood/Public/blob/master/XKCD%20Password%20Generatror/New-SecurePassword.ps1

CHANGELOG
- VERSION 1.0 - LAST MODIFIED: 2019.02.16
  - Original version from https://www.reddit.com/r/PowerShell/comments/arccbg/update_xkcd_password_generator/
- VERSION 2.0 - LAST MODIFIED: 2023-12-20
  - Expands the script to have more flexibility and more closely match the version found on XKPASSWD, but implimented entirely in PowerShell
#>
function New-SecurePassword {
    [cmdletBinding()]
    [OutputType([string])]
    
    Param( 
        # The number of words to include
        [ValidateRange(1,24)]
        [int]$WordCount = 3, 

        # The minimum length of words to consider
        [ValidateRange(1,24)]
        [int]$MinWordLength = 4,

        # the maximum length of words to consider
        [ValidateRange(1,24)]
        [int]$MaxWordLength = 8,

        # How to transform the words
        [ValidateSet("None","alternatingWORDcase","CapitaliseFirstLetter","cAPITALIZEeVERYlETTERbUTfIRST","lowercase","UPPERCASE","RandomCapitalise")]
        [String]$Transformations = "AlternatingWordCase",

        # Separator character randomly chosen from this set
        [char[]]$Separator = @("!","@","$","%","^","&","*","-","_","+","=",":","|","~","?","/",".",";"),

        # Padding digits at the front of the password
        [int]$FrontPaddingDigits = 2, 

        # Padding digits at the end of the password
        [int]$EndPaddingDigits = 2, 

        # Padding symbols at the front of the password
        [int]$FrontPaddingSymbols = 2, 

        # Padding symbols at the end of the password
        [int]$EndPaddingSymbols = 2, 

        # Padding character randomly chosen from this set
        [char[]]$PaddingSymbols = @("!","@","$","%","^","&","*","-","_","+","=",":","|","~","?","/",".",";"),

        # An array of strings to use as the dictionary
        [string[]]$Dictionary = $ExampleDictionary
    )
    
    begin {
        # DEFINE VARIABLES
        [String]$PWStructure = ""
        [Int]$MinLength = 0
        [Int]$MaxLength = 0
        [string]$SecurePassword = ""
    }
    
    process {
        <#
        (Verbose) Display password structure and length
        1. Select padding symbols
        2. Select padding numbers
        3. Select separator
        4. Select random words
          filter dictionary to just words in word length
          get random number in array length
          Use random number to get array entry
        5. Select padding numbers
        6. Select padding symbols
        #>

        if ($MinWordLength -le $MaxWordLength) {
            if (($MinWordLength -lt 24) -and $MaxWordLength -lt 24){
                [string[]]$FilteredDictionary = $Dictionary | Where-Object {($_.Length -ge $MinWordLength) -and ($_.Length -le $MaxWordLength)}
            } elseif (($MinWordLength -eq 24) -or ($MaxWordLength -eq 24)) {
                [string[]]$FilteredDictionary = $Dictionary | Where-Object {$_.Length -ge $MinWordLength}
            }
        } else {
            Write-Warning "Minimum word length is greater than maximum word length."
            return
        }

        Write-Verbose "Dictionary contains $($Dictionary.Count) words."
        Write-Verbose "$($FilteredDictionary.Count) potential words selected."

        # If verbosity is enabled, generate the password structure then write it out
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            if ($FrontPaddingSymbols) {
                For( $C=1; $C -le $FrontPaddingSymbols; $C++ ) {
                    $PWStructure += '[P]'
                    $MinLength++
                }
            }
            if ($FrontPaddingDigits) {
                For( $C=1; $C -le $FrontPaddingDigits; $C++ ) {
                    $PWStructure += '[D]'
                    $MinLength++
                }
            }
            if ($Separator -and $FrontPaddingDigits) {
                $PWStructure += '[S]'
                $MinLength++
            }
            For( $C=1; $C -le $WordCount; $C++ ) {
                $PWStructure += '[Word]'
                $MinLength += $MinWordLength
                $MaxLength += $MaxWordLength - $MinWordLength
                if ($Separator -and $C -lt $WordCount) {
                    $PWStructure += '[S]'
                    $MinLength++
                }
            }
            if ($Separator -and ($EndPaddingDigits)) {
                $PWStructure += '[S]'
                $MinLength++
            }
            if ($EndPaddingDigits) {
                For( $C=1; $C -le $EndPaddingDigits; $C++ ) {
                    $PWStructure += '[D]'
                    $MinLength++
                }
            }
            if ($EndPaddingSymbols) {
                For( $C=1; $C -le $EndPaddingSymbols; $C++ ) {
                    $PWStructure += '[P]'
                    $MinLength++
                }
            }
            $MaxLength += $MinLength
            $VerboseMessage = "Structure: $($PWStructure)"
            Write-Verbose $VerboseMessage
            $VerboseMessage = "Length: "
            if ($MinLength -eq $MaxLength) {
                $VerboseMessage += "always $($MinLength) characters"
            } else {
                $VerboseMessage += "between $($MinLength) and $($MaxLength) characters"
            }
            Write-Verbose $VerboseMessage
        }

        # Select a random padding symbol from the provided array
        if ($PaddingSymbols) {
            $PadSymbol = $PaddingSymbols[(Get-RandomInt -Min 0 -Max ($PaddingSymbols.Count - 1))]
        }
        
        # Select a random separator character from the provided array
        if ($Separator) {
            $SeparatorChar = $Separator[(Get-RandomInt -Min 0 -Max ($Separator.Count - 1))]
        }

        # Add padding symbols to the beginning of the password, if included
        if ($FrontPaddingSymbols) {
            For( $C=1; $C -le $FrontPaddingSymbols; $C++ ) {
                $SecurePassword += $PadSymbol
            }
        }
        # Add padding digits to the beginning of the password, if included
        if ($FrontPaddingDigits) {
            For( $C=1; $C -le $FrontPaddingDigits; $C++ ) {
                $SecurePassword += Get-RandomInt -Min 0 -Max 9
            }
        }

        # Place a separator between the above and the first word, if included
        if ($Separator -and $FrontPaddingDigits) {
            $SecurePassword += $SeparatorChar
        }

        # Add the words to the password, using the selected transformation, separated by the separator characters, if applicable
        For( $C=1; $C -le $WordCount; $C++ ) {
            $CurrentWord = $FilteredDictionary[(Get-RandomInt -Min 0 -Max ($FilteredDictionary.Count - 1))]
            If ($Transformations = "None") {
                $SecurePassword += $CurrentWord
            } elseif ($Transformations = "alternatingWORDcase") {
                if ([bool]!($C % 2)) {
                    $SecurePassword += $CurrentWord.ToUpper()
                } else {
                    $SecurePassword += $CurrentWord.ToLower()
                }
            } elseif ($Transformations = "CapitaliseFirstLetter") {
                $SecurePassword += $CurrentWord.Substring(0,1).ToUpper() + $CurrentWord.Substring(1).ToLower()
            } elseif ($Transformations = "cAPITALIZEeVERYlETTERbUTfIRST") {
                $SecurePassword += $CurrentWord.Substring(0,1).ToLower() + $CurrentWord.Substring(1).ToUpper()
            } elseif ($Transformations = "lowercase") {
                $SecurePassword += $CurrentWord.ToLower()
            } elseif ($Transformations = "UPPERCASE") {
                $SecurePassword += $CurrentWord.ToUpper()
            } elseif ($Transformations = "RandomCapitalise") {
                if ((Get-RandomInt -Min 0) % 2) {
                    $SecurePassword += $CurrentWord.ToUpper()
                } else {
                    $SecurePassword += $CurrentWord.ToLower()
                }
            }
            if ($Separator -and $C -lt $WordCount) {
                $SecurePassword += $SeparatorChar
            }
        }

        # Place a separator between the words and the end padding digits/symbols, if applicable
        if ($Separator -and $EndPaddingDigits) {
            $SecurePassword += $SeparatorChar
        }

        # Add padding digits to the end of the password, if included
        if ($EndPaddingDigits) {
            For( $C=1; $C -le $EndPaddingDigits; $C++ ) {
                $SecurePassword += Get-RandomInt -Min 0 -Max 9
            }
        }

        # Add padding symbols to the end  of the password, if included
        if ($EndPaddingSymbols) {
            For( $C=1; $C -le $EndPaddingSymbols; $C++ ) {
                $SecurePassword += $PadSymbol
            }
        }
    }

    end {
        # Return the generated password
        Return $SecurePassword
    }
}

<#
.SYNOPSIS
This function will return a random number.

.DESCRIPTION
This function takes two numbers and returns a random number between those two numbers. It defaults to the minimum and maximum possible value for an integer, which is a range of 4,294,967,295

.PARAMETER Min
The minimum number to consider. Defaults to the minimum value for an integer (-2147483648)

.PARAMETER Max
The maximum number to consider. Defaults to the maximum value for an integer (2147483647)

.EXAMPLE
Get-RandomInt -Min 0 -Max 100

81

This example generates a random number between 0 and 100

.EXAMPLE
Get-RandomInt -Min 0

1461304439

This example generates a random number between 0 and [Int]::MaxValue

.EXAMPLE
Get-RandomInt

-1728936647

This example generates a random number between [Int]::minValue and [Int]::MaxValue

.NOTES
General notes
#>
function Get-RandomInt {
    [CmdletBinding()]
    param (
        # The lowest number to include. Defaults to the lowest possible number
        [Parameter()][int]$Min = [Int]::MinValue,
        
        # the highest number to include
        [Parameter()][int]$Max = [Int]::MaxValue
    )
    
    process {
        if ($Min -lt $Max) {
            $Return = [System.Security.Cryptography.RandomNumberGenerator]::GetInt32($Min,$Max)
        } else {
            Write-Warning 'Minimum length must be less than Maximum length'
            return -1
        }
    }
    
    end {
        return $Return
    }
}
