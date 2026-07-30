# Control4 NEXT 

## From Stuck to Seamless: Creating Custom Control4 Drivers

### Setting Up Your Coding Environment

1. GitHub
2.	Visual Studio Code
a.	Download and install from https://code.visualstudio.com
b.	Launch Visual Studio Code
c.	Install the Github Copilot extension
d.	Activate by logging in with your Github account
3.	Download (using the <> Code button) and unzip https://github.com/snap-one/c4next-driver-development-main.
4.	Download and unzip https://github.com/snap-one/drivers-driverpackager-master and place in the c4next-driver-development-main folder.
5.	Open the c4next-driver-development-main folder in Visual Studio Code.
6.	Open the README.md file for further instructions that are Mac or Windows specific.


#### Mac
1.	Open the Terminal application.
2.	Find out which python environment: 
    ``` 
    python --version
    ```
    or try 
    ```
    python3 --version 
    ```
3.	If not version 3.11, do the following:
    1. Install homebrew: https://brew.sh
    2. Install python version 3.11: 
        ```
        brew install python@3.11
        ```
4. If wanting to encrypt drivers (optional) then install swig and openssl:
    ```
    brew install swig openssl
    ```
5.	Create a virtual environment: 
    ```
    python -m venv .venv
    ```
6.	Activate your virtual environment: 
    ```
    source .venv/bin/activate
    ```
7.	Install dependency of lxml: 
    ```
    pip install lxml
    ```
8.	Install optional dependency of M2Crypto (for encryptying drivers): 
```
env LDFLAGS="-L$(brew --prefix openssl)/lib" CFLAGS="-I$(brew --prefix openssl)/include" SWIG_FEATURES="-cpperraswarn -includeall -I$(brew --prefix openssl)/include" pip install m2crypto
```
9.	Change directories: 
```
cd test-compile
```
10.	Run the test compile for a driver: 
```
python ../drivers-driverpackager-master/dp3/driverpackager.py ./ ./../compiled/ test_compile.c4zproj
```
	
#### Windows

1.	Run PowerShell as administrator
2.	Set the policy to allow for running python scripts
```
Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
```
3.	Create a virtual environment: 
```
python -m venv .venv
```
4.	Activate your virtual environment: 
```
.venv\Scripts\activate
```
5.	Install dependency of lxml: 
```
pip install lxml
```
6.	Install optional dependency of M2Crypto (for encryptying drivers): 
```
pip install M2Crypto
```
7.	Change directories: 
```
cd test-compile
```
8.	Run the test compile for a driver: 
```
python ..\drivers-driverpackager-master\dp3\driverpackager.py .\ .\..\compiled test_compile.c4zproj
```