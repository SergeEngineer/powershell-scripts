

Get-ChildItem "C:\temp" -Recurse -File -ErrorAction SilentlyContinue | Where CreationTime -lt  (Get-Date).AddDays(-14)  | Remove-Item -ErrorAction SilentlyContinue -Force -Recurse

Get-ChildItem "C:\Windows\Temp\" -Recurse -File -ErrorAction SilentlyContinue | Where CreationTime -lt  (Get-Date).AddDays(-14)  | Remove-Item -ErrorAction SilentlyContinue -Force -Recurse 

Get-ChildItem "C:\iislogs" -Recurse -File -ErrorAction SilentlyContinue | Where CreationTime -lt  (Get-Date).AddDays(-14)  | Remove-Item -ErrorAction SilentlyContinue -Force -Recurse
