@where deno > nul
@if %ERRORLEVEL% neq 0 echo "Deno is not installed. Please see how to install Deno at https://deno.land/#installation"
@deno run --allow-read --allow-net https://deno.land/std@0.88.0/http/file_server.ts