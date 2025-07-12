VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
#--------------------------------------------------
# TODO: 
# 1. Need to address rolling of files, 
# 2. maintain a buffer and log rather than log to file every log statement
#------------------------------------------------
Attribute VB_Name = "Logger"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Private mDebugEnabled As Boolean
Private mLogFile As String
Private iFileNumber As Long
Private consoleLogging As Boolean
Private fileLogging As Boolean
Private Sub Class_Initialize()
    mDebugEnabled = False
    mLogFile = "C:\logs\default.log"
    fileLogging = False
End Sub
Private Sub Class_Terminate()
    mLogFile = ""
    mDebugEnabled = False
    consoleLogging = False
    Close #iFileNumber
End Sub
Public Sub init(ByVal logFile As String, ByVal aDebugEnabled As Boolean)
    If logFile <> "" Then
        mLogFile = logFile & "\" & "default.log"
    End If
    mDebugEnabled = aDebugEnabled
    On Error Resume Next
    Name mLogFile As logFile & "\default.log." & Year(Now()) & "-" & Month(Now()) & "-" & Day(Now()) & "-" & Hour(Now())
    On Error GoTo ERRORHANDLER
    iFileNumber = FreeFile(1)
    Open mLogFile For Append Shared As #iFileNumber
    fileLogging = True
Exit Sub
ERRORHANDLER:
    Debug.Print "[Error] Failed to open file for logging event. Details: " & Err.Source & " " & Err.Number & " " & Err.Description
    fileLogging = False
End Sub
Public Sub logDebug(ByVal log As String)
    If mDebugEnabled Then
       WriteLogFile "[Debug] - " & CStr(Now()) & " - " & log
    End If
End Sub

Public Function isDebug() As Boolean
isDebug = mDebugEnabled
End Function

Public Sub logInfo(ByVal log As String)
    WriteLogFile "[Info] - " & CStr(Now()) & " - " & log
End Sub

Public Sub logError(ByVal log As String)
    WriteLogFile "[Error] - " & CStr(Now()) & " - " & log
End Sub

Sub WriteLogFile(ByVal log As String)
    If fileLogging = True Then
          Print #iFileNumber, log
    End If
    Debug.Print log
End Sub
