## JumpStart

Start by reading the description and purpose of [JumpStart](https://github.com/snap-one/docs-driverworks/tree/master/Jumpstart). JumpStart can help you create certain types of drivers more quickly, but only *if* you understand how to configure it, what the configuration generates, and how to modify the generated code. This tutorial will walk you through installing and configuring JumpStart, generating driver code with it, and then modifying the code.

### Install and Configure JumpStart

1. In your terminal, navigate to the folder where you want to keep the JumpStart files, and clone the docs-driverworks repository:
  ```sh
  git clone https://github.com/snap-one/docs-driverworks.git
  ```
2. Add a sibling folder called my-jumpstart-drivers:
  ```sh
  mkdir my-jumpstart-drivers
  ```

  Your folder structure should look like this: 
  ```
  parent folder/
  ├── docs-driverworks/
  └── my-jumpstart-drivers/
  ```

3. Open the **my-jumpstart-drivers** folder in **Visual Studio Code** by dragging it onto the application or selecting **File** > **Open Folder**.
4. Copy the **Jumpstart** and **JumpRefresh** executables for Windows or Linux from **docs-driverworks/Jumpstart/executables/** into your **my-jumpstart-drivers** folder. Technically, you don't need to do this unless you're using the Mac workaround, but it's convenient to have everything in the same folder.
5. Create a file named **JumpStartEnvironment.json** with the following contents:
    ```json
    {
      "General": {
          "TemplateDir": "my-jumpstart-templates",
          "WorkDir": "",
          "IncludeLuacheck": false
      },
      "Build": {
          "BuildMethod": "DriverPackager"
      }
    }
    ```

    JumpStart uses this file to locate your templates and determine where to generate the driver code. The `""` value for `WorkDir` indicates that the current folder will hold the generated drivers. The `BuildMethod` value of `DriverPackager` tells JumpStart to create a `.c4zproj` file along with the code.
    
    You can read more about this file and how it can be specified in the [DriverWorks Fundamentals](https://snap-one.github.io/docs-driverworks-fundamentals/#getting-started-with-jumpstart-jumpstartenvironment-json) documentation.

6. Create a folder named **my-jumpstart-templates**.
7. Copy **docs-driverworks/Jumpstart/SampleDriverFiles/AcmeTv.json** to **my-jumpstart-drivers/my-jumpstart-templates** so you can modify the sample driver if you would like.

### Generate Your Driver Code with JumpStart

1. In **Visual Studio Code**, press **Ctrl - `** to open the **integrated terminal**.
2. In the terminal, generate the JumpStart template code using this pattern: `[JumpStart executable] [JumpStart driver configuration file] [JumpStart environment file]`. For example:

    ```sh
    JumpStart.exe .\my-jumpstart-templates\AcmeTV.json .\JumpStartEnvironment.json
    ```
    or for Linux:

    ```sh
    ./JumpStart ./my-jumpstart-templates/AcmeTV.json ./JumpStartEnvironment.json
    ```
3. This command should generate a **tv_ACME** folder in your directory. It contains many folders and files. You shouldn't need to modify the generated folders, except for the **www** folder. The files you might need to edit are in the main driver folder:

| File | Edit it when you need to... |
|---|---|
| `driver.xml` | Change the driver specifications: identity, proxy capabilities, Composer properties, commands, actions, events, or connections. The more you configure in the template file, the less you will have to modify the driver.xml file.|
| `device_specific.lua` | Configure the driver, initialize the chosen modules, react to Composer properties, handle communication state. This is the primary file you will modify. |
| `[communication method]_specific.lua` | For each communication method you specify in the template, a file for coding the handling of each method is generated. For example, with the TV, there were three methods, so there are `network_device_specific.lua`, `serial_device_specific.lua`, and `ir_device_specific.lua` files. |
| `tv_ACME.lua` | Keep vendor-specific Lua objects, protocol constants, message builders, parsers, and state that does not belong to the reusable template. |
| `driver.lua` | Normally you can leave this file as is, but you may have code that makes better sense in this file if it applies to the life cycle of the driver. |

Do not modify `common/`, `network/`, `serial/`, `ir/`, `tv_proxy/`, `lib/`, or `modules/` for normal device work. They are copied template modules. Read them to understand an API only.
     
### Recreate the Random Number Generator Driver Using JumpStart

To help you understand what JumpStart can generate and how it is structured, let's use something familiar: the Random Number Generator.

1. Create a template file named **JSRandomNumber.json** in the **my-jumpstart-templates** folder.
2. In this JSON file, you'll configure the driver in JSON rather than XML. Compare it with the `driver.xml` file from the previous Random Number Generator driver. Add the following code to the file:
    ```json
    {
      "DriverName": "js_random_number",
      "Copyright": "C4NEXT",
      "Manufacturer": "C4NEXT",
      "Creator": "Ken Torgerson",
      "Name": "JumpStart Random Number Generator",
      "Model": "Non Device",
      "Proxies": [
        {
          "Proxy": "Combo",
          "Name": "js_random_number"
        }
      ],
      "Properties": [
        { 
          "Name": "Max Number",
          "Type":"RANGED_INTEGER",
          "ReadOnly": "False",
          "Default":"5",
          "Min":"2",
          "Max": "20"
        }
      ],
      "Actions": ["Generate New Number"],
      "Events": [{
        "Name": "RandomNumberGenerated",
        "Description": "Event fired when a new random number is generated"
      }],
      "Commands": [
        {
          "Name": "GenerateNewNumber",
          "Description": "Generate a new random number"
        }
      ]
    }
    ```
3. In the **integrated terminal**, run the JumpStart executable:
    ```sh
    JumpStart.exe .\my-jumpstart-templates\JSRandomNumber.json .\JumpStartEnvironment.json
    ```
    or for Linux:

    ```sh
    ./JumpStart ./my-jumpstart-templates/JSRandomNumber.json ./JumpStartEnvironment.json
    ```

4. The newly created **js_random_number** folder contains the generated driver files.

### Modify the Driver Code

For this driver, you'll modify two different files. Technically, you could modify only **device_specific.lua**, but for this tutorial, we'll have you modify another file as well.

1. In **device_specific.lua**, create the `RANDOM_NUMBER` variable:

    ```lua
    function ON_DRIVER_INIT.AddRandomNumberVariable()
        C4:AddVariable("RANDOM_NUMBER", 1, "NUMBER")
    end
    ```
    Notice that the syntax is different. The `OnDriverInit` function is already in the base code. When Director runs `OnDriverInit()` in **common/c4_init.lua**, the code runs any functions defined in the `ON_DRIVER_INIT` table. This means you can define multiple functions in **device_specific.lua**:
    ```lua
    function ON_DRIVER_INIT.functionOne()
    -- function 1 code here
    end

    function ON_DRIVER_INIT.functionTwo()
    --function 2 code here
    end
    ```
    All of these functions will run, provided they are defined in the `ON_DRIVER_INIT` table using the `ON_DRIVER_INIT.FunctionName()` format.

    Some of the functions using JumpStart syntax and the DriverWorks functions that run the JumpStart functions are defined below:

    | JumpStart Syntax | DriverWorks API Function |
    |---|---|
    | `ON_DRIVER_EARLY_INIT.Name(initType)` | `OnDriverInit(initType)`|
    | `ON_DRIVER_INIT.FunctionName(initType)` | `OnDriverInit(initType)`. The early-init and init tables run in sequence within `OnDriverInit(initType)`, which lets you control the order in which functions run during driver initialization.|
    | `ON_DRIVER_LATEINIT.FunctionName(initType)` | `OnDriverLateInit(initType)` |
    | `ON_DRIVER_DESTROYED.FunctionName(initType)` | `OnDriverDestroyed(initType)` |
    | `ON_PROPERTY_CHANGED.PropertyName(propertyValue)` | `OnPropertyChanged(propertyName)` |
    | `EX_CMD.CommandName(tParams)` | `ExecuteCommand(sCommand, tParams)` |
    | `PRX_CMD.ProxyCommandName(bindingId, tParams)` | `ReceivedFromProxy(idBinding, sCommand, tParams)` |

    There's more to consider, but this should give you an idea of how the code is structured and standardized. This structure makes it easier to organize the code and find your custom code.

2. In the **js_random_number.lua** file, create a function to generate a random number:

    ```lua
    function js_random_number:GenerateRandomNumber()
      local maxNumber = tonumber(Properties["Max Number"]) or 2
      local randomNumber = math.random(1, maxNumber)

      C4:SetVariable("RANDOM_NUMBER", randomNumber)
      TriggerEvent_RandomNumberGenerated()
      LogInfo("Generated Random Number: " .. randomNumber)
    end
    ```
    You could structure this differently and put the code in **device_specific.lua** as well, but in this case, we're putting the common function here. This should look very similar to the code in the original driver, but there are two important distinctions:
        
    1. First, the `TriggerEvent_RandomNumberGenerated()` function refers to code that JumpStart generated because we defined the event in the template configuration file. If you look at that function, you'll see the event being fired just as we'd expect:
        ```lua
        function TriggerEvent_RandomNumberGenerated()
          LogTrace("TriggerEvent_RandomNumberGenerated")
          C4:FireEvent("RandomNumberGenerated")
        end
        ```

        One of the advantages of using JumpStart is that it generates code you likely need based on what you define. You'll notice another generated function:

        ```lua
        function ON_PROPERTY_CHANGED.MaxNumber(propertyValue)
            LogTrace("ON_PROPERTY_CHANGED.MaxNumber")
        end
        ```

        We happen not to need to modify this function, but if we did, it would already be generated.

    2. Second, you'll notice a `LogInfo` function. Another advantage is that logging is automatically built into the driver, so we can turn it on when needed and get more information about the code as it runs.

3. Next, we need to add a call to `js_random_number:GenerateRandomNumber()` in both the action and command handlers. Both functions already exist, so we just need to add this one line to each:

    ```lua
    function LUA_ACTION.GenerateNewNumber()
        LogTrace("LUA_ACTION.GenerateNewNumber")
        js_random_number:GenerateRandomNumber()
    end
    ```

    ```lua
    EX_CMD["GenerateNewNumber"] = function (tParams)
      LogTrace("GenerateNewNumber")
      js_random_number:GenerateRandomNumber()
      LogInfo(tParams)
    end
    ```

Obviously, the Random Number Generator is a very simple driver. And frankly, it was easier to code without JumpStart, and it generated a much smaller driver. But most drivers aren't so simple. When coding a driver for an actual device with multiple communication methods, connections, or other complexities, JumpStart can actually help you shortcut the development process by generating an easy-to-use codebase.

### Bonus: JumpStart for Mac Users
You don't need to feel left out if you're a Mac user. You can run the Linux executable by installing **Docker** and making a small change to your shell configuration file. If you're using an older Mac with an Intel chip, make sure to check whether these instructions need to be adjusted. You do this at your own risk!

1. Install [**Docker Desktop**](https://www.docker.com/products/docker-desktop).
2. Edit your `.zshrc` file, or create it in your home directory if it doesn't exist (for example, `/Users/[yourusername]/.zshrc`):

```sh
jumpstart() {
  docker run --platform linux/amd64 --rm -it -v "$PWD":/work -w /work ubuntu:24.04 "$@"
}
```

3. In the **terminal** you will type:

```sh
jumpstart ./JumpStart ./SampleDriverFiles/AcmeTv.json ./JumpStartEnvironment.json
```
The first time you run this command, Docker downloads Ubuntu 24.04. On subsequent runs, it uses the locally cached image. This setup assumes that the JumpStart executable is in the working directory where you run the command.

