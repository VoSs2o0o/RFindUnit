# RFindUnit - Version 1.3.0 BETA

###Todo's
- second checkmark at implementation part
- additional source code dirs to parse
- e.g. TFile creates a lot of hits => new filtermethod
- latest DelphiAST
- DCU32Int via Code (exe Tool at moment)

Find unit (find uses) is a very simple tool and very used (Ctrl+Shift+A), but, as you know Delphi Find Unit doesn't work very well, in general it crashes or it's very slow.

Currently it have the basics expected features, and I'm working to organize, optmize and give it new functions (as auto import for example).
If you help, it'll be very good.

### How does it work in practice ?
[![IMAGE ALT TEXT](https://i.ytimg.com/vi/SYNUQcg_y58/hqdefault.jpg)](https://i.ytimg.com/vi/SYNUQcg_y58/hqdefault.jpg "Demonstration")


### Automatically Identify unused imports
First enable it: 

![Enable feature](https://github.com/VoSs2o0o/RFindUnit/blob/master/Resources/ExperimentalFeature.png)

Process: 

![Process the file](https://github.com/VoSs2o0o/RFindUnit/blob/master/Resources/ProcessingUses.png)

Show if everything is right:

![Show all ok](https://github.com/VoSs2o0o/RFindUnit/blob/master/Resources/CheckedAndOK.png)

Or if there are some unused units:

![Highlight unused uses](https://github.com/VoSs2o0o/RFindUnit/blob/master/Resources/CheckedAndNotOk.png)

### Find unit feature
Before: 

![Default Version](http://i.imgur.com/8DZPGSs.png)

After:

![RFindUnit Screen](https://github.com/VoSs2o0o/RFindUnit/blob/master/Resources/RFindUnitImage.png)

### Auto organize uses feature
It's possible to auto organize uses (Ctrl + Shift + U). It's possible to sort then by alphabetical order and split it by line and namespae, as you can see: 

Before:

![Before](https://github.com/VoSs2o0o/RFindUnit/blob/master/Resources/organizeBefore.png)

After:

![After](https://github.com/VoSs2o0o/RFindUnit/blob/master/Resources/organizeAfter.png)

### Installation
Delphi 10.1 or newer
1. Download [the project](https://github.com/VoSs2o0o/RFindUnit/archive/refs/heads/master.zip), or clone the project.
1. Go to the Packages directory and choose your corresponding version
2. Open the RFindUnit.dproj on your Delphi and right click on the project and install it.

![Example](https://github.com/VoSs2o0o/RFindUnit/blob/master/Resources/InstallationHelp.png)


#### Contact
VoSs2o0o

info@cloud-9.de

#### Referenced Projects
* [DelphiAST](https://github.com/RomanYankovsky/DelphiAST)
* [Log4Pascal](https://github.com/martinusso/log4pascal)
* [Dcu32Int] (https://github.com/VoSs2o0o/dcu32int)
* [Dcu32Int Original](https://github.com/rfrezino/DCU32INT)

