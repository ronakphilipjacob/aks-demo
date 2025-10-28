var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

// Configure the HTTP request pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}

app.UseStaticFiles();
app.UseRouting();

// Root endpoint
app.MapGet("/", () =>
{
    var html = @"
        <!DOCTYPE html>
        <html lang=""en"">
        <head>
            <meta charset=""UTF-8"">
            <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
            <title>AppB</title>
            <style>
                body {
                    font-family: Arial, sans-serif;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                    background-color: #f0f8ff;
                }
                .container {
                    text-align: center;
                    padding: 2rem;
                    background-color: white;
                    border-radius: 10px;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }
                h1 {
                    color: #333;
                    margin-bottom: 1rem;
                }
                .app-info {
                    color: #666;
                    font-size: 1.2rem;
                }
            </style>
        </head>
        <body>
            <div class=""container"">
                <h1>Hi from AppB!</h1>
                <p class=""app-info"">.NET Microservice</p>
                <p>Environment: " + app.Environment.EnvironmentName + @"</p>
            </div>
        </body>
        </html>";
    
    return Results.Content(html, "text/html");
});

// Health check endpoint
app.MapGet("/health", () => new { 
    status = "healthy", 
    app = "AppB", 
    technology = ".NET",
    environment = app.Environment.EnvironmentName
});

app.Run();