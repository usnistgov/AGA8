VERSION 5.00
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   3015
   ClientLeft      =   60
   ClientTop       =   525
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3015
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton EndCommand 
      Caption         =   "End"
      Height          =   495
      Left            =   480
      TabIndex        =   0
      Top             =   1560
      Width           =   1575
   End
   Begin VB.Label TimerLabel 
      BorderStyle     =   1  'Fixed Single
      Height          =   495
      Left            =   480
      TabIndex        =   1
      Top             =   840
      Width           =   1575
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub EndCommand_Click()
  End
End Sub

Private Sub Form_Load()
  Dim ierr As Integer, i As Integer
  Dim x(21) As Double, Mm As Double, T As Double, P As Double, D As Double
  Dim time1 As Double, time2 As Double
  Dim Z As Double, dPdD As Double, dPdD2 As Double, dPdT As Double, U As Double, H As Double, S As Double, Cv As Double, Cp As Double, W As Double, G As Double, JT As Double, k As Double
  Dim herr As String * 255

  Show
  DoEvents
  Call SetupGERG
  Call SetupDetail
  x(1) = 0.77942
  x(2) = 0.02
  x(3) = 0.06
  x(4) = 0.08
  x(5) = 0.03
  x(6) = 0.0015
  x(7) = 0.003
  x(8) = 0.00052
  x(9) = 0.00145
  x(10) = 0.00215
  x(11) = 0.00088
  x(12) = 0.00024
  x(13) = 0.00015
  x(14) = 0.00009
  x(15) = 0.004
  x(16) = 0.005
  x(17) = 0.002
  x(18) = 0.0001
  x(19) = 0.0025
  x(20) = 0.007
  x(21) = 0#
  T = 400
  P = 1
  'Open "d:\data.dat" For Output As #2
  time1 = Timer
  Call MolarMassGERG(x, Mm)
  EndCommand.Enabled = False
  For i = 1 To 10000
    P = P * 1.0001
    T = T * 1.0001
    Call DensityGERG(0, T, P, x, D, ierr, herr)
    'Print #2, T, P, D
    'Call Density(T, P, x, D, ierr, herr)
    'Call PropertiesGERG(T, D, x, P, Z, dPdD, dPdD2, dPdT, U, H, S, Cv, Cp, W, G, JT, k)
  Next
  time2 = Timer
  time1 = time2 - time1
  TimerLabel = CSng(time1)
  EndCommand.Enabled = True
End Sub
