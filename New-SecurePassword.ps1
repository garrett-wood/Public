#XKCD PASSWORD GENERATOR

#VERSION 1.0
#LAST MODIFIED: 2019.02.16

<#
.SYNOPSIS
    This function creates random passwords using user defined characteristics. It is inspired by the XKCD 936
    comic and the password generator spawned from it, XKPasswd.

.DESCRIPTION    
    
    This function uses available dictionary files and the user's input to create a random memorable password.
    The dictionary files should be placed in C:\Scripts\. It can be used to generate passwords for a variety 
    of purposes and can also be used in combination with other functions in order to use a single line 
    password set command. This function can be used without parameters and will generate a password using 4 
    words between 5 and 15 characters each.

.PARAMETER MinWordLength
   
   This parameter is used to set the minimum individual word length used in the password. The full range is 
   between 1 and 24 characters. Selecting 24 will include all words up to 31 characters (it's not many).
   Its recommended value is 5. If none is specified, the default value of 5 will be used.

.PARAMETER MaxWordLength

   This parameter is used to set the maximum individual word length used in the password. The full range is 
   between 1 and 24 characters. Selecting 24 will include all words up to 31 characters (it's not many).
   Its recommended value is 15. If none is specified, the default value of 15 will be used.

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
        $MinWordLength = 5,
        
        [ValidateRange(1,24)]        
        [int]
        $MaxWordLength = 15,
        
        [ValidateRange(1,24)]        
        [int]
        $WordCount = 4, 
        
        [int]$MaxLength = 65535, 
        
        [switch]$NoSymbols = $False, 
        
        [switch]$NoNumbers = $False 

    )
        
                
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
            $DictionaryPath = ('C:\Scripts\Words_' + $WordLength + '.txt')
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
    

    #PROVIDE RANDOM PASSWORD  
    Return $FinalPassword
}