# Control4 NEXT 

## From Stuck to Seamless: Creating Custom Control4 Drivers

### Setting Up Your Coding Environment

1. GitHub
2.	Visual Studio Code
    1.	Download and install from https://code.visualstudio.com
    2.	Launch Visual Studio Code
    3.	Install the Github Copilot extension
    4.	Activate by logging in with your Github account
3.	Download (using the <> Code button > Download Zip) and unzip the repo at https://github.com/snap-one/c4next-driver-development.
4.	Download (using the <> Code button > Download Zip) and unzip https://github.com/snap-one/drivers-driverpackager and place in the c4next-driver-development-main folder.
5.	Open the c4next-driver-development-main folder in Visual Studio Code.
6.	Open the README.md file for further instructions that are specific to Mac or Windows.


#### Mac

1.	Open the Terminal application and change directory (`cd`) to the c4next-driver-development-main folder.
2.	Find out which python environment: 
    ```sh 
    python --version
    ```
    or try 
    ```sh
    python3 --version 
    ```
3.	If not version 3.11, do the following:
    1. Install homebrew: https://brew.sh
    2. Open a new terminal window and install python version 3.11: 
        ```sh
        brew install python@3.11
        ```
4. If wanting to encrypt drivers (optional) then install swig and openssl:
    ```sh
    brew install swig openssl
    ```
5.	Create a virtual environment: 
    ```sh
    python -m venv .venv
    ```
6.	Activate your virtual environment: 
    ```sh
    source .venv/bin/activate
    ```
7.	Install dependency of lxml: 
    ```sh
    pip install lxml
    ```
8.	Install optional dependency of M2Crypto (for encryptying drivers): 
```sh
env LDFLAGS="-L$(brew --prefix openssl)/lib" CFLAGS="-I$(brew --prefix openssl)/include" SWIG_FEATURES="-cpperraswarn -includeall -I$(brew --prefix openssl)/include" pip install m2crypto
```
9.	Change directories: 
```sh
cd test-compile
```
10.	Run the test compile for a driver: 
```sh
python ../drivers-driverpackager-master/dp3/driverpackager.py ./ ./../compiled/ test_compile.c4zproj
```
	
#### Windows

1.	Run PowerShell as administrator and change directory (`cd`) to the c4next-driver-development-main folder.
2.	Check if python is installed:
```sh
python --version
```
3. If not installed, install it through the Windows Store popup, and follow the defaults until you get back to the command line, at which point `python --version` should respond with `Python 3.14.7` or later.
4.	Set the policy to allow for running python scripts
```sh
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```
5.	Create a virtual environment: 
```sh
python -m venv .venv
```
6.	Activate your virtual environment: 
```sh
.venv\Scripts\activate
```
7.	Install dependency of lxml: 
```sh
pip install lxml
```
8.	Install optional dependency of M2Crypto (for encryptying drivers): 
```sh
pip install M2Crypto
```
9.	Change directories: 
```sh
cd test-compile
```
10.	Run the test compile for a driver: 
```sh
python ..\drivers-driverpackager-master\dp3\driverpackager.py .\ .\..\compiled test_compile.c4zproj
```
