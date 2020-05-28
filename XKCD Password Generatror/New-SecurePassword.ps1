#XKCD PASSWORD GENERATOR

#VERSION 2.0
#LAST MODIFIED: 2020.05.28

<#
.SYNOPSIS
    This function creates random passwords using user defined characteristics. It is inspired by the XKCD 936
    comic and the password generator spawned from it, XKPasswd.

.DESCRIPTION    
    
    This function uses available dictionary files and the user's input to create a random memorable password.
    The dictionary files should be placed in your PowerShell profile directory in a subfolder. They are used 
    to generate passwords and can also be used in combination with other functions in order to use a single 
    line password set command. This function can be used without parameters and will generate a password using
    2 words between 6 and 16 characters each.

.PARAMETER MinWordLength
   
   This parameter is used to set the minimum individual word length used in the password. The full range is 
   between 1 and 24 characters. Selecting 24 will include all words up to 31 characters (it's not many).
   Its recommended value is 6, which is also the default.

.PARAMETER MaxWordLength

   This parameter is used to set the maximum individual word length used in the password. The full range is 
   between 1 and 24 characters. Selecting 24 will include all words up to 31 characters (it's not many).
   Its recommended value is 16, which is also the default.

.PARAMETER WordCount

   This parameter is used to set the number of words in the password generated. The full range is between 1
   and 24 words. Caution is advised at any count higher than 10

.PARAMETER MaxLength

   This parameter overrides the full length of the password by cutting it off after the number of characters
   specified. Its only recommended use is where password length is determined by maximums for an application.

.PARAMETER NoSymbols

   This parameter prevents any symbols from being used in the password. Its only recommended use is where
   symbols are disallowed by the application.

.PARAMETER NoNumbers

   This parameter prevents any numbers from being used in the password. Its only recommended use is where
   numbers are disallowed by the application.

.RELATED LINKS
    
    XKCD Comic 936: https://xkcd.com/936/
    XKPasswd:       https://xkpasswd.net/
    
#>    
function New-SecurePassword 
{
    [cmdletBinding()]
    [OutputType([string])]
    
    Param
    ( 
        [ValidateRange(1,24)]
        [int]
        $MinWordLength = 6,
        
        [ValidateRange(1,24)]        
        [int]
        $MaxWordLength = 12,
        
        [ValidateRange(1,24)]        
        [int]
        $WordCount = 2,
        
        [ValidateRange(1,24)]        
        [int]
        $Count = 1,
        
        [int]$MaxLength = 65535, 
        
        [switch]$NoSymbols = $False, 
        
        [switch]$NoNumbers = $False 

    )
        
    #VALIDATE DICTIONARY FILE PRESENCE
    $FileLengths = 1..24
    $LocalPath = (([environment]::getfolderpath("mydocuments") + '\WindowsPowerShell\XKCD-Password-Generator\'))
    $GitHubPath = 'https://raw.githubusercontent.com/garrett-wood/Public/master/XKCD%20Password%20Generatror/Words_'

    $TestFolder = Test-Path $LocalPath
    If ($TestFolder -eq $True)
        {
        ForEach ($File in $FileLengths)
            {
            $TestResult = Test-Path ($LocalPath + "Words_" + $File + ".txt")
            If ($TestResult -eq $False)
                {
                Write-Warning "Missing Dictionary File Words_$file.txt. Downloading."
                Invoke-WebRequest -Uri ($GitHubPath + "$File.txt") -OutFile ($LocalPath + "Words_" + "$File.txt")
	            }
            }
        }
    Else 
        {
        Write-Warning "Directory Missing. Creating and downloading dictionary files."
        New-Item -Type Directory -Path $LocalPath
        ForEach ($File in $FileLengths)
            {
            Invoke-WebRequest -Uri ($GitHubPath + "$File.txt") -OutFile ($LocalPath + "Words_" + "$File.txt")
            }
        }            


    #GENERATE RANDOM PASSWORD(S)
    $FinalPasswords = @()
    For( $Passwords=1; $Passwords -le $Count; $Passwords++ )
    {
    

        #GENERATE RANDOM LENGTHS FOR EACH WORD
        $WordLengths =  @()
        For( $Words=1; $Words -le $WordCount; $Words++ ) 
            {
            [System.Security.Cryptography.RNGCryptoServiceProvider]  $Random = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
            $RandomNumber = new-object byte[] 1
            $WordLength = ($Random.GetBytes($RandomNumber))
            [int] $WordLength = $MinWordLength + $RandomNumber[0] % 
            ($MaxWordLength - $MinWordLength + 1) 
            $WordLengths += $WordLength 
            }
                
                
        
        #PICK WORD FROM DICTIONARY MATCHING RANDOM LENGTHS
        $RandomWords = @()
        ForEach ($WordLength in $WordLengths)
            {
            $DictionaryPath = ($LocalPath + 'Words_' + $WordLength + '.txt')
            $Dictionary = Get-Content -Path $DictionaryPath
            $MaxWordIndex = Get-Content -Path $DictionaryPath | Measure-Object -Line | Select -Expand Lines
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            #I don't know why but when the below line is commented out, the function breaks and returns the same words each time.
            $RandomSeed = $Random.GetBytes($RandomBytes)
            $RNG = [BitConverter]::ToUInt32($RandomBytes, 0)
            $WordIndex = ($Random.GetBytes($RandomBytes))
            [int] $WordIndex = 0 + $RNG[0] % 
            ($MaxWordIndex - 0 + 1)
            $RandomWord = $Dictionary | Select -Index $WordIndex
            $RandomWords += $RandomWord
            }

   
        #RANDOMIZE CASE
        $RandomCaseWords = ForEach ($RandomWord in $RandomWords) 
            {
            $ChangeCase = Get-Random -InputObject $True,$False
            If ($ChangeCase -eq $True) 
                {
                $RandomWord.ToUpper()
                }
            Else 
                {
                $RandomWord
                }
            }
    

        #ADD SYMBOLS
        If ($NoSymbols -eq $True) 
            {
            $RandomSymbolWords = $RandomCaseWords
            }
        Else 
            {
            $RandomSymbolWords = ForEach ($RandomCaseWord in $RandomCaseWords) 
                {
                $Symbols = @('!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+')
                $Prepend = Get-Random -InputObject $Symbols
                $Append = Get-Random -InputObject $Symbols
                [System.String]::Concat($Prepend, $RandomCaseWord, $Append)
                }
            }
    
    
        #ADD NUMBERS
        If ($NoNumbers -eq $True) 
            {
            $NumberedPassword = $RandomSymbolWords
            }
        Else 
            {
            $NumberedPassword = ForEach ($RandomSymbolWord in $RandomSymbolWords) 
                {
                $Numbers = @("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
                $Prepend = Get-Random -InputObject $Numbers
                $Append = Get-Random -InputObject $Numbers
                [System.String]::Concat($Prepend, $RandomSymbolWord, $Append)
                }
            }


        #JOIN ALL ITEMS IN ARRAY
        $FinalPasswordString = $NumberedPassword -Join ''


        #PERFORM FINAL LENGTH CHECK
        If ($FinalPasswordString.Length -gt $MaxLength) 
            {
            $FinalPassword = $FinalPasswordString.substring(0, $MaxLength)
            }
        Else 
            {
            $FinalPassword = $FinalPasswordString
            }

        #JOIN GENERATED PASSWORDS TO ARRAY
        $FinalPasswords += $FinalPassword

    }

    #PROVIDE RANDOM PASSWORD  
    Return $FinalPasswords
}
