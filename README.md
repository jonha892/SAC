# SAC - Savoy Availability Checker

## TODO Environment
- [x] Windows 'ding' ändern

- [ ] Raspberry Pi architecture
  - [ ] How to run the app?
    - [ ] docker-compsoe for DB plus SAC?
    - [ ] persistent storage
      - [ ] backup

## TODO v2 elixir:
- [ ] Refactoring
  - [x] Secrets in env
  - [ ] Verbessern der Nachrichten
    - [ ] Sprache (OV,  OmU, ...)
  - [x] Als Server mit Aufruf alle 15min
    - [x] Funktionen in Module
    - [ ] Fehlerbehandlung
      - [ ] DEFAULT -> logging
        - [ ] persistente Log file
        - [ ] bei kritischem Fehler, mehrmals versuchen, sonst BOT offline schalten, und dann sehen wir das manuell
      - [ ] kein Film wird gefunden --> 
      - [ ] Savoy Seite kann nicht aufgerufen werden
        - [ ] Response codes pruefen? --> 
      - [ ] Discordfehler
        - [ ] TBD
      - [ ] E-Mail Fehler
        - [ ] TBD
      - [ ] Datenbankfehler? - sollten von Docker abgefangen werden
        - [ ] TBD
    
- [ ] Find out how to seperate and make good use of different dev and prod environments
  - [ ] different configs?
  - [ ] different DB names

- [x] Health check -> reporting
  - [x] Heartbeat -> Raspberry Pi
  - [x] works via status of BOT - if offline the app is down

- [ ] Database
  - [ ] Concurrency
  - [ ] Manuelle Manipulation der DB ermoeglichen
  - [ ] What to store?
    - [ ] E-Mail
      - [ ] How long?
      - [ ] Discord USER or some name
    - [ ] Seen movies
      - [ ] How long?
      - [ ] First time found
      - [ ] First time found with playtime
      - [ ] How often a movie was found (for different playtimes)
      - [ ] Extra handling for reoccuring events (weekly Sneak Preview, "Film Club") --> maybe delete movies after some time

- [ ] Discord Server ausbauen
  - [ ] Eigene Reaction Emojis
  - [ ] Channel message

- [ ] Anmeldung nicht nur via Discord, sondern...
  - [ ] manuell?

- [ ] Discord Bot ausbauen
  - [ ] Listen to exact message
  - [x] USER clicks on REACTION
  - [x] USER gets assigned ROLE
  - [x] ROLE can see CHANNEL
  - [x] ROLE unregister Discord
  - [ ] Email registrieren
    - [ ] USER clicks on REACTION
    - [ ] BOT sends a message to the user asking for their E-Mail
      - [ ] check the input to only allow valid E-Mail format?
        - [ ] At least disallow some nonsense?
    - [ ] BOT sends a verification E-Mail consisting of a VERIFICATION CODE to the supplied address
    - [ ] BOT asks USER to reply with the VERIFICATION CODE
    - [ ] If USER answers with anything other than exactly the code, the BOT will ask for a total of 3 times, then the verification has to be done again by clicking the REACTION (either the USER gets their ROLE revoked or gets asked to remove the REACTION and add it again)
    - [ ] If USER answers with the code, the BOT sends a SUCCESSFUL REGISTRATION E-Mail
      - [ ] and adds that E-Mail to  the RECIPIENTS list
  - [ ] ROLE unregister Email
    - [ ] When USER removes REACTION, the E-Mail is removed from