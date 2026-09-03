## Set Up the Project and Package the Driver
1.	In Visual Studio Code press Ctlr - ` to open the integrated terminal.
4.	In the integrated terminal, enter the virtual environment: 
```sh
source .venv/bin/activate
```
5.	Change the directory by typing cd random-number-generator and pressing Enter.
6.	Package the driver: 
```sh
python [path to the driver packager folder]/dp3/driverpackager.py ./ ./../compiled random_number.c4zproj
```

or for Windows

```sh
python [path to the driver packager folder]\dp3\driverpackager.py .\ .\..\compiled random_number.c4zproj
```
7.	In Composer Pro, click **Driver > Add or Update Driver or Agent**.
8.	Choose the packaged driver in the compiled folder.
9.	When added, go to the Search tab and type random in the search bar.
10.	Add the Random Number Generator driver to the Equipment Rack room.
