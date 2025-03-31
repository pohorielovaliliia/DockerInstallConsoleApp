using System.Diagnostics;
using System.Text;

class Program
{
    static void Main()
    {
        string filePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "install-result.txt");

        using (StreamWriter writer = new StreamWriter(filePath, true))
        using (TextWriter consoleWriter = Console.Out)
        {
            writer.AutoFlush = true;
            Console.SetOut(new MultiTextWriter(consoleWriter, writer));

            Console.WriteLine("Starting Process...");
            string scriptPath = GetScriptPath("install-docker-offline.ps1");
            //string scriptPath = GetScriptPath("remove-docker.ps1");
            ExecuteScript(scriptPath);
            Console.WriteLine("\n\nPress any key to close this window . . .");
            Console.ReadLine();
        }
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

class MultiTextWriter : TextWriter
{
    private readonly TextWriter _consoleWriter, _fileWriter;

    public MultiTextWriter(TextWriter consoleWriter, TextWriter fileWriter)
    {
        _consoleWriter = consoleWriter;
        _fileWriter = fileWriter;
    }

    public override Encoding Encoding => _consoleWriter.Encoding;

    public override void WriteLine(string value)
    {
        string timestampedValue = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} - {value}";
        _consoleWriter.WriteLine(value);
        _fileWriter.WriteLine(timestampedValue);
    }

    public override void Write(char value)
    {
        _consoleWriter.Write(value);
        _fileWriter.Write(value);
    }
}

