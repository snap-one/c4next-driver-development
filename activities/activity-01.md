## Set Up the Project and Package the Driver
1.	In **Visual Studio Code** press **Ctlr - `** to open the **integrated terminal**.
2.	In the **integrated terminal**, enter the virtual environment:
```sh
source .venv/bin/activate
```
3.	Change the directory by typing `cd random-number-generator` and pressing **Enter**.
4.	Package the driver:
    #### Mac
    ```sh
    python [path to the driver packager folder]/dp3/driverpackager.py ./ ./../compiled random_number.c4zproj
    ```

    ### Windows

    ```sh
    python [path to the driver packager folder]\dp3\driverpackager.py .\ .\..\compiled random_number.c4zproj
    ```
5.	In **Composer Pro**, click **Driver > Add or Update Driver or Agent**.
6.	Choose the packaged driver in the **compiled** folder.
7.	When added, go to the **Search** tab and type `random` in the **search bar**.
8.	Add the **Random Number Generator** driver to the **Equipment Rack** room.
