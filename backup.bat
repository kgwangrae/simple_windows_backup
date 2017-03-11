@echo off
setlocal

:: To prevent illegal backup attempts by changing the target external storage with the same drive letter. (F:\ in this case.)
:: Simply put same key in all the source and target drives.
echo "Authenticating keys..."

certutil -hashfile c:\b_key.txt sha512 > b_key_c_checksum.txt
for /f "tokens=1*delims=:" %%G in ('findstr /n "^" b_key_c_checksum.txt') do if %%G equ 2 set KEYC=%%H
certutil -hashfile d:\b_key.txt sha512 > b_key_d_checksum.txt
for /f "tokens=1*delims=:" %%G in ('findstr /n "^" b_key_d_checksum.txt') do if %%G equ 2 set KEYD=%%H
certutil -hashfile e:\b_key.txt sha512 > b_key_e_checksum.txt
for /f "tokens=1*delims=:" %%G in ('findstr /n "^" b_key_e_checksum.txt') do if %%G equ 2 set KEYE=%%H
certutil -hashfile f:\b_key.txt sha512 > b_key_f_checksum.txt
for /f "tokens=1*delims=:" %%G in ('findstr /n "^" b_key_f_checksum.txt') do if %%G equ 2 set KEYF=%%H

if not "%KEYC%"=="0d 3a fa 54 1d 14 14 cd b3 4a f4 c3 68 d4 4b c4 5f 0e 63 87 60 ff c6 dc 6e c8 b1 eb c1 d9 e4 09 49 a5 09 c0 be 81 58 52 f0 27 32 c6 cc 2d 9a e0 5d 02 b9 be 06 31 2f bf 0f cd f5 2b 56 62 44 36" (
  goto nokey
) else if not "%KEYC%"=="%KEYD%" (
  goto nokey
) else if not "%KEYD%"=="%KEYE%" (
  goto nokey
) else if not "%KEYF%"=="%KEYF%" (
  goto nokey
)
goto backup

:nokey
echo "Authentication failed... keys in the source and target drives are invalid."
exit -1

:backup
:: F:\ may use exFAT (no symlink supported) instead of NTFS.
:: (If NTFS is used, robocopy with /MIR option will follow symlinks only in the F drive and destroy all the files they point to (not the symlinks themselves - https://superuser.com/questions/567877/robocopy-mir-or-purge-follows-and-deletes-target-symlinks)
robocopy e:\ f:\e /MIR /ZB /W:1 /R:0 /XJ /XJD /SL /ETA /a-:hs /mt /log:f:\log_e.txt /tee
robocopy d:\ f:\d /MIR /ZB /W:1 /R:0 /XJ /XJD /SL /ETA /a-:hs /mt /log:f:\log_d.txt /tee
robocopy c:\ f:\c /MIR /ZB /W:1 /R:0 /XJ /XJD /SL /ETA /a-:hs /mt /log:f:\log_c.txt /tee

endlocal