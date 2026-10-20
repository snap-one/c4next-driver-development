# Control4 NEXT 

## From Stuck to Seamless: Creating Custom Control4 Drivers

Welcome to Control4 NEXT! Before your class, it is critical for you to set up your coding environment.

### Setting Up Your Coding Environment

To setup your environment you will be: 
* Setting up a GitHub account and installing Git. This is so you can easily download the code repository of the class and keep it updated.
* Downloading (cloning) the class repository and the driver packager code to your computer.
* Installing or updating the Python programming language interpreter for your computer.
* Installing Visual Studio Code as your code editor and installing GitHub Copilot to help with your code.
* Creating a virtual Python environment to install the code packages you need for compiling a driver.
* Running a test compile of a driver to make sure it is all working.
	
#### Windows
1.	GitHub and Git
    1.	Create a free account at https://github.com if you don't already have one.
    2.	Download and install Git from https://git-scm.com/downloads/win, accepting the defaults.
    3.	Verify the install by opening a terminal (or PowerShell) and running:
        ```sh
        git --version
        ```

2.	Run PowerShell as administrator.

3. Navigate to the folder where you will install the code repositories using: 
    ```sh
    cd path\to\parent\folder
    ```

4.	Clone the repo at https://github.com/snap-one/c4next-driver-development:
    ```sh
    git clone https://github.com/snap-one/c4next-driver-development.git
    ```

5.	Clone https://github.com/snap-one/drivers-driverpackager next to (not inside) the `c4next-driver-development` folder, so the two folders are siblings:
    ```sh
    git clone https://github.com/snap-one/drivers-driverpackager.git
    ```
    Your folder structure should look like this:
    ```
    parent folder/
    ├── c4next-driver-development/
    └── drivers-driverpackager/
    ```

6.	Check if python is installed:
    ```sh
    python --version
    ```

7. If not installed, or the version is below `Python 3.14.7`, install it through the Windows Store popup, and follow the defaults until you get back to the command line, at which point `python --version` should respond with `Python 3.14.7` or later.

8.	Set the policy to allow for running python scripts
    ```sh
    Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
    ```
    If you are unable to set the policy using the local machine scope try setting it with the current user:
    ```sh
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

9.	Visual Studio Code
    1.	Download and install from https://code.visualstudio.com
    2.	Launch Visual Studio Code
    3.	Install the Github Copilot extension
    4.	Activate by logging in with your Github account
    5. Open the `c4next-driver-development` folder in Visual Studio Code by dragging the folder to the application or using **File** > **Open Folder**
    6.	Press **Ctrl - `** to open the **integrated terminal**.

10.	In the **integrated terminal**, Create a virtual environment: 
    ```sh
    python -m venv .venv
    ```

11.	Activate your virtual environment: 
    ```sh
    .venv\Scripts\Activate.ps1
    ```

12.	Install dependency of lxml: 
    ```sh
    pip install lxml
    ```

13.	Install optional dependency of M2Crypto (for encryptying drivers): 
    ```sh
    pip install M2Crypto
    ```

14.	Change directories: 
    ```sh
    cd test-compile
    ```

15.	Run the test compile for a driver: 
    ```sh
    python .\..\..\drivers-driverpackager\dp3\driverpackager.py .\ .\..\compiled test_compile.c4zproj
    ```

16. Verify the driver was created by looking in the **compiled** folder.

17. In PowerShell, deactivate the virtual environment by typing: 
    ```sh
    deactivate
    ```

18. Create working copies of the **random-number-generator** and the **ultimate-button-driver** folders. This is so Git won't "git" after you for modifying the files from the repository.
    1. Duplicate the **random-number-generator** folder and rename it to **random-number-generator-working**.
    2. Duplicate the **ultimate-button-driver** folder and rename it to **ultimate-button-driver-working**.


#### Mac

1.	GitHub and Git
    1.	Create a free account at https://github.com if you don't already have one.
    2.	Open the Terminal application and run `git --version`. If it isn't already installed, you'll be prompted to install the Xcode Command Line Tools, which include Git.
    
2. Navigate to the folder that you will use to install the code repositories:
    ```sh
    cd path/to/parent/folder
    ```

3.	Clone the repo at https://github.com/snap-one/c4next-driver-development:
    ```sh
    git clone https://github.com/snap-one/c4next-driver-development.git
    ```

4.	Clone https://github.com/snap-one/drivers-driverpackager next to (not inside) the `c4next-driver-development` folder, so the two folders are siblings:
    ```sh
    git clone https://github.com/snap-one/drivers-driverpackager.git
    ```
    Your folder structure should look like this:
    ```
    parent folder/
    ├── c4next-driver-development/
    └── drivers-driverpackager/
    ```

5.	Find out which python environment: 
    ```sh 
    python --version
    ```
    or try 
    ```sh
    python3 --version 
    ```

6.	If not version 3.11, do the following:
    1. Install homebrew: https://brew.sh
    2. Open a new terminal window and install python version 3.11: 
        ```sh
        brew install python@3.11
        ```
    3. You may have to add the path to this version in your terminal configuration:
        ```sh
        echo 'export PATH="$(brew --prefix)/opt/python@3.11/libexec/bin:$PATH"' >> ~/.zshrc
        ```

7. If wanting to encrypt drivers (optional) then install swig and openssl:
    ```sh
    brew install swig openssl
    ```

8.	Visual Studio Code
    1.	Download and install from https://code.visualstudio.com
    2.	Launch **Visual Studio Code**
    3.	Install the Github Copilot extension
    4.	Activate by logging in with your Github account
    5. Open the `c4next-driver-development` folder in Visual Studio Code by dragging the folder to the application or using **File** > **Open Folder**
    6. In **Visual Studio Code** press **Ctrl - `** to open the **integrated terminal**.

9.	In the **integrated terminal**, create a virtual environment: 
    ```sh
    python -m venv .venv
    ```

10.	Activate your virtual environment: 
    ```sh
    source .venv/bin/activate
    ```

11.	Install dependency of lxml: 
    ```sh
    pip install lxml
    ```

12.	Install optional dependency of M2Crypto (for encryptying drivers): 
    ```sh
    env LDFLAGS="-L$(brew --prefix openssl)/lib" CFLAGS="-I$(brew --prefix openssl)/include" SWIG_FEATURES="-cpperraswarn -includeall -I$(brew --prefix openssl)/include" pip install m2crypto
    ```

13.	Change directories: 
    ```sh
    cd test-compile
    ```

14.	Run the test compile for a driver: 
    ```sh
    python ./../../drivers-driverpackager/dp3/driverpackager.py ./ ./../compiled/ test_compile.c4zproj
    ```

15. Verify the driver was created by looking in the **compiled** folder.

16. Deactivate the virutal environment: 
    ```sh
    deactivate
    ```
17. Create working copies of the **random-number-generator** and the **ultimate-button-driver** folders. This is so Git won't "git" after you for modifying the files from the repository.
    1. Duplicate the **random-number-generator** folder and rename it to **random-number-generator-working**.
    2. Duplicate the **ultimate-button-driver** folder and rename it to **ultimate-button-driver-working**.
