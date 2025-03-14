using System.Diagnostics;

class Program
{
    static void Main()
    {
        Console.WriteLine("Starting Process...");
        string scriptPath = GetScriptPath("install-docker-offline.ps1");
        //string scriptPath = GetScriptPath("remove-docker.ps1");
        ExecuteScript(scriptPath);
        Console.WriteLine("\n\nPress any key to close this window . . .");
        Console.ReadLine();
    }

public static string GetScriptPath(string scriptFileName)
{
    // Get the folder where the .exe is located
    string exeDirectory = AppDomain.CurrentDomain.BaseDirectory;

    // Combine it with the relative path to app-data
    string scriptPath = Path.Combine(exeDirectory, "app-data", scriptFileName);

    // Ensure the file exists
    if (!File.Exists(scriptPath))
        throw new FileNotFoundException($"Script not found: {scriptPath}");

    return scriptPath;
}
public static void ExecuteScript(string pathToScript)
    {
        var scriptArguments = $"-ExecutionPolicy Bypass -File \"{pathToScript}\"";

        var processStartInfo = new ProcessStartInfo("powershell.exe", scriptArguments)
        {
            Verb = "runas", // Run as admin
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            UseShellExecute = false,
            CreateNoWindow = true
        };

        using var process = new Process { StartInfo = processStartInfo };

        // Event Handlers for real-time output
        process.OutputDataReceived += (sender, e) => { if (e.Data != null) Console.WriteLine(e.Data); };
        process.ErrorDataReceived += (sender, e) => { if (e.Data != null) Console.WriteLine(e.Data); };

        // Start the process
        process.Start();

        // Begin reading output asynchronously
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();

        // Wait for script execution to complete
        process.WaitForExit();
    }
}

