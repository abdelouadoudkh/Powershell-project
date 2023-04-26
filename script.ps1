Import-Module ActiveDirectory 

#---- réponse question numéro 1 ----
function Choisir-Domaine{


    $domains = (Get-ADForest).Domains

    Write-Host "Les ADs disponible:" 
    for($i = 0; $i -lt $domains.Count; $i++){
        #-lt less than/ la boucle continue à tourner seulement si $i < $domains.Count
        # $domains: array of AD name //using Get-ADForest
        Write-Host "$i $($domains[$i])"
    }

    $choixDomaine = Read-Host "Saisissez le numéro du domaine que vous souhaiter administrer"
    $DomaineChoisi = $domains[$choixDomaine]
    $credential = Get-Credential

    Set-ADDomain -Identity $DomaineChoisi -Credential $credential

    return Write-Host "vous avez choisi : $DomaineChoisi"

} # fin réponse numéro 1

#---- réponse question numéro 2 ----
function Get-DomainControllers{
    Get-ADDomainController -Filter * | Select-Object Name
}
# fin réponse numéro 2

#---- réponse question numéro 3 ----
function Get-ActiveUsers{

    $users =  Get-ADUser -Filter {Enabled -eq $true} 

    foreach($user in $users){
        $userDN = $user.DistinguishedName # DN c'est le nom unique qui identifie l'entrée dans le répertoir
        $division = ($userDN -split ',')[1].Substring(3)
        $DisplayName = $user.Name
        $UserPrincipalName = $user.UserPrincipalName
        $userMail = $user.EmailAddress # email is missing :)


        Write-Host "DisplayName :  $DisplayName"
        Write-Host "UserPrincipalName :  $UserPrincipalName"
        Write-Host "Division :  $division"
        Write-Host "Email :  $userMail `n"

    }
}# fin réponse numéro 3

#---- réponse question numéro 4 ----
function Get-ADGroups {
    # Récupère tous les groupes avec leur type de groupe correspondant
    $groups = Get-ADGroup -Filter * -SearchBase "OU=Utilisateurs,DC=lab,DC=local" -Properties GroupCategory

    # Parcours chaque groupe et détermine son type de groupe
    foreach ($group in $groups) {
        $type = if ($group.GroupCategory -eq 'Security') { 'Sécurité' } else { 'Distribution' }
        #-eq === est égal à puis returne true or false
        # Retourne le nom du groupe et son type de groupe
        [PSCustomObject]@{ # is a class to format data
            'Nom du groupe' = $group.Name
            'Type de group' = $type
        }
    }
}# fin réponse numéro 4

#---- réponse question numéro 5 ----
function Get-GroupInfo {

    $inputGrpName = Read-Host "Choisir le groupe"

    $usergrp = Get-ADGroupMember $inputGrpName |Get-ADUser -Filter {Enabled -eq $true} 

    foreach($i in $usergrp){
        $temp = $i.DistinguishedName 
        $division = ($temp -split ',')[1].Substring(3)
        $DisplayName = $i.Name
        $UserPrincipalName = $i.UserPrincipalName
        $userMail = $i.EmailAddress # email is missing :)


        Write-Host "DisplayName :  $DisplayName"
        Write-Host "UserPrincipalName :  $UserPrincipalName"
        Write-Host "Division :  $division"
        Write-Host "Email :  $userMail `n"
    }
}# fin réponse numéro 5


#---- réponse question numéro 6 ----
function Rechercher-User{
    $recherche = Read-Host -Prompt "Tapez le nom complet de l'utilisateur à chercher"
    $filtre = 'Name -eq "' + $recherche + '"'
    $utilisateurs = Get-ADUser -Filter $filtre -Properties EmailAddress| select DisplayName, Name, EmailAddress
    Write-Host $utilisateurs
}# fin réponse numéro 6

#---- réponse question numéro 7 ----
function ModifierMDP-User{
    $recherche = Read-Host -Prompt "Tapez le nom complet de l'utilisateur à chercher"
    $filtre = 'Name -like "' + $recherche + '"'
    $utilisateurs = Get-ADUser -Filter $filtre

    $nouveauMDP = Read-Host -Prompt "Entrez le nouveau mdp de l'utilisateur : "
    Set-ADAccountPassword -Identity $utilisateurs -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $nouveauMDP -Force)
}#fin réponse numéro 7

#---- réponse question numéro 8 ----
function ActiverCompte-User{
    $recherche = Read-Host -Prompt "Tapez le nom complet de l'utilisateur à chercher"
    $filtre = 'Name -like "' + $recherche + '"'
    $utilisateurs = Get-ADUser -Filter $filtre

    Enable-ADAccount -Identity $utilisateurs
}# fin réponse numéro 8

#---- réponse question numéro 9 ----
function Ajouter-User{
    New-ADUser -Name (Read-Host "Entrez le nom : ") -Accountpassword (Read-Host -AsSecureString "Entrez le MDP : ") -Enabled $true -path "OU=Utilisateurs, DC=lab, DC=local"
}
# fin réponse numéro 9

$loop = $true

while ($loop){

    Write-Host "           ----Menu----"
    Write-Host "1. Choisir le domaine AD à administrer"
    Write-Host "2. Lister tous les controleurs de domaines"
    Write-Host "3. Lister tous les utilisateurs"
    Write-Host "4. Lister tous les groupes"
    Write-Host "5. Lister les utilisateurs d'un groupe"
    Write-Host "6. Rechercher un utlisateur"
    Write-Host "7. Modifier le mot de passe d'un utilisateur"
    Write-Host "8. Débloquer un utilisateur"
    Write-Host "9. Ajouter un utilisateur `n" # `n = new line
    Write-Host "q. Quitter l'application `n"

    $result = "Au revoir !"
    $input = Read-Host "Choisissez l'action à exécuter"

    switch( $input ){
       "1" {$result = Choisir-Domaine}
       "2" {$result = Get-DomainControllers}
       "3" {$result = Get-ActiveUsers}
       "4" {$result = Get-ADGroups}
       "5" {$result = Get-GroupInfo}
       "6" {$result = Rechercher-User}
       "7" {$result = ModifierMDP-User}
       "8" {$result = ActiverCompte-User}
       "9" {$result = Ajouter-User}

       "q" {$loop = $false}

       default {$result = "`n /!\ Entrez un caractère valide /!\ `n"}
    }

    $result

}