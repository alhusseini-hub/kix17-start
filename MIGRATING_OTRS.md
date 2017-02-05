# English Version

The following describes the migration from OTRS to KIX. It's absolutely necessary to fulfill all the requirements and to follow the steps.

## Requirements

* the OTRS system is on the same framework version like KIX
 * i.e. 5.0.8, see /opt/kix/RELEASE after the installation of KIX
 * please make sure you have a consistent package stack (corresponding versions)
* the OTRS system uses the same DBMS like KIX (PostgreSQL, MariaDB or MySQL)
* the KIX database must be local

# Steps

* stop the daemon in the OTRS system
 * ```sudo -u www-data <OTRS-Home>/bin/otrs.Daemon.pl stop```
* stop cronjobs in the OTRS system
 * ```<OTRS Home>/bin/Cron.sh stop <OTRS user>```
* stop apache
* go to the KIX application directory 
 * ```cd /opt/kix``` 
* execute migration script
 * ```scripts/migrate_otrs2kix.sh```
  * follow the instuctions
  * wait... 
* copy special config from your OTRS Config.pm to KIX Config.pm
 * copy your old SystemID to the SystemID config attribute in the KIX Config.pm 
 * do not change the rest of the existing KIX config! 
* remove old OTRS config from apache
* deactivate mod_perl
 * this is only necessary if you want to work in both systems
* start apache
* re-install the remaining installed packages using the console package manager
 * ```sudo -u <apache user> /opt/kix/bin/otrs.Console.pl Admin::Package::Reinstall --force <package name>```
* copy article attachments in the filesystem from old OTRS installation to KIX
 * ```cp -rvp <OTRS-Home>/var/article /opt/kix/var```
* if exists, copy CI images in the filesystem from old OTRS installation to KIX
 * ```cp -rvp <OTRS-Home>/var/ITSMConfigItem /opt/kix/var```
* if exists, copy CI attribute attachments in the filesystem from old OTRS installation to KIX
 * ```cp -rvp <OTRS-Home>/var/attachments /opt/kix/var```
* rebuild Config
* clear caches
* reload apache
* check cronjobs in KIX system
 * copy special cronjobs and adjust and validate configuration
* start cronjobs in KIX system
 * ```/opt/kix/bin/Cron.sh start <apache user>```
* start daemon in KIX system
 * ```sudo -u www-data /opt/kix/bin/otrs.Daemon.pl start```

# Deutsche Version

Im Folgenden wird das Vorgehen für die Migration einer OTRS-Instanz auf KIX beschrieben. Es ist zwingend notwendig, die Voraussetzungen zu erfüllen und die Schritte einzuhalten. 

## Voraussetzungen
* das OTRS-System ist auf gleichem Framework-Stand wie KIX 
 * z.B. 5.0.8, siehe /opt/kix/RELEASE nach Installation von KIX
 * bitte sicherstellen, dass ein konsistenter Paketstack vorliegt (zusammenpassende Paketversionen)
* das OTRS-System verwendet das gleiche DBMS wie KIX (PostgreSQL, MariaDB oder MySQL) 
* die KIX-Datenbank muss lokal installiert sein

## Vorgehen

* Daemon in OTRS-Instanz stoppen
 * ```sudo -u www-data <OTRS-Home>/bin/otrs.Daemon.pl stop```
* Cronjobs in OTRS-Instanz stoppen
 * ```<OTRS-Home>/bin/Cron.sh stop <OTRS-Nutzer>```
* Apache stoppen
* ins KIX-Verzeichnis wechseln
 * ```cd /opt/kix``` 
* Migrationsscript ausführen
  * ```scripts/migrate_otrs2kix.sh```
   * Instruktionen folgen
   * warten... 
* spezielle Konfigurationen aus der alten Config.pm in die neue Config.pm von KIX übertragen
 * die alte SystemID in das SystemID-Config-Attribut der KIX Config.pm kopieren 
 * nicht die restliche bestehende KIX-Konfiguration überschreiben!  
* alte OTRS config aus Apache entfernen
* mod_perl deaktivieren
 * nur notwendig, falls man parallel in OTRS und KIX arbeiten will
* Apache starten 
* abschließend die übrigen installierten Pakete im Paket-Manager auf der Console re-installieren
 * ```sudo -u <apache user> /opt/kix/bin/otrs.Console.pl Admin::Package::Reinstall --force <package name>```
* die Artikel-Attachments im Dateisystem von der alten OTRS-Installation nach KIX kopieren
 * ```cp -rvp <OTRS-Home>/var/article /opt/kix/var```
* falls vorhanden, die CI-Bilder im Dateisystem von der alten OTRS-Installation nach KIX kopieren
 * ```cp -rvp <OTRS-Home>/var/ITSMConfigItem /opt/kix/var```
* falls vorhanden, die CI-Attribute-Attachments im Dateisystem von der alten OTRS-Installation nach KIX kopieren
 * ```cp -rvp <OTRS-Home>/var/attachments /opt/kix/var```
* Config rebuild
* Caches löschen
* Apache reload
* Cronjobs in KIX-Instanz prüfen
 * spezielle Cronjobs übertragen und Konfiguration prüfen und ggf. anpassen
* Cronjobs in KIX-Instanz starten
 * ```/opt/kix/bin/Cron.sh start <Apache-Nutzer>```
* Daemon in KIX-Instanz starten
 * ```sudo -u www-data /opt/kix/bin/otrs.Daemon.pl start```
