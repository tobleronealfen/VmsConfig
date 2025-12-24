VMS Server/Klient Konfiguration v1.0
Note regarding language: This project, including the script interface, documentation, and wiki, is primarily in Danish, as it is tailored for Danish-speaking technicians and environments.

Dette script er udviklet til at automatisere opsætningen af Windows-maskiner i Milestone XProtect-miljøer. Formålet er at eliminere manuelle konfigurationsfejl og sikre, at hardwaren yder maksimalt uden afbrydelser fra Windows' standardfunktioner.

[Download VmsScript.bat](https://raw.githubusercontent.com/Brugernavn/Repo/main/VmsScript.bat?download=true)

Formål
Windows er fra fabrikken optimeret til strømbesparelse og kontorbrug. I et professionelt VMS-miljø er dette uhensigtsmæssigt, da det kræver uafbrudt drift, konstant disk-skrivning og øjeblikkelig CPU-respons. Dette script konfigurerer systemet til dedikeret 24/7 overvågningsdrift.

Gennemgang af valgmuligheder
1. Automatisk Login

Målgruppe: Smart Client-maskiner.


Funktion: Aktiverer AutoAdminLogon i registreringsdatabasen med specifikt brugernavn og password.




Anvendelse: Essentielt for visningsstationer, hvor operatøren ikke skal indtaste adgangskoder manuelt efter en genstart eller strømafbrydelse.

2. Deaktivering af Screensaver og Dvale

Målgruppe: Smart Client-maskiner / Overvågningsstationer.


Funktion: Sætter monitor-, standby- og hibernate-timeout til 0 på både AC og DC.


Anvendelse: Tiltænkt maskiner, der skal køre 24/7 med konstant visning af live-video, uden at skærmen går i sort.

3. Deaktivering af Windows Update

Målgruppe: Servere.


Funktion: Sætter NoAutoUpdate politikken i registreringsdatabasen.


Anvendelse: Sikrer, at serveren ikke genstarter uventet pga. opdateringer, hvilket minimerer nedetid.

4. Høj Ydeevne (Hardware + Visuelt)

Målgruppe: Servere.


Funktion: Aktiverer strømplanen "Høj ydeevne" (GUID: 8c5e7fda...) og deaktiverer unødvendige visuelle effekter.


Anvendelse: Gør serveren i stand til at håndtere tung video-processering uden at CPU'en drosler ned for at spare strøm.

5. NTP Server (Tidsserver)

Målgruppe: Servere.


Funktion: Aktiverer NtpServer tjenesten og sætter AnnounceFlags til 5.


Anvendelse: Gør det muligt for kameraer og andre enheder at synkronisere deres ure direkte mod serveren for korrekte tidsstempler.

6. NTP Client (Synkronisering)

Målgruppe: Servere og Klienter.


Funktion: Konfigurerer manualpeerlist mod en specifik IP-adresse eller DNS-navn.


Anvendelse: Bruges til at holde serverens eget ur synkroniseret efter en ekstern eller intern master-tidskilde.

7. Autostart Smart Client

Målgruppe: Smart Client-maskiner.


Funktion: Opretter en genvej i Windows' "Run" nøgle til Smart Client-eksekverbare fil.


Anvendelse: Gør maskinen til en dedikeret visningsstation, der starter videovisning op automatisk uden brugerinteraktion.

8. Deaktivering af Indeksering

Målgruppe: Servere (Storage-mapper).


Funktion: Bruger PowerShell til at sætte NotContentIndexed attributten på den valgte sti.


Anvendelse: Skal anvendes på drev til videooptagelser for at fjerne unødig disk-belastning fra Windows Search.

9. Skift af baggrundsbillede

Målgruppe: Alle enheder.


Funktion: Sætter background.png eller background.jpg som permanent tapet.


Anvendelse: Giver visuel bekræftelse på, at maskinen er færdigkonfigureret og klar til drift.

Logning og Dokumentation
Efter kørsel genereres en detaljeret logfil i scriptets mappe med navnet VmsConfig_[DATO]_[TID].log. Loggen indeholder:


Systeminformation (Computer og bruger).

Oversigt over alle valgte og fravalgte konfigurationer.

Detaljeret status for hver enkelt eksekvering (OK/FEJL).



Udviklet af: Jan Kousholt - jkousholt@gmail.com - 2025
