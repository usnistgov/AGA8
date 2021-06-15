//Globals variables of this page
let Background=[];
let webButtons=[];
let SumOfComponents;
let iFlag=1;
const CanvasLeterColor=[0,0,0];
const TextColor='White';
function preload(){
    Background[0] = loadImage('99_Images/Background_0.png');
    Background[1] = loadImage('99_Images/Background_1.png');
    Background[2] = loadImage('99_Images/Background_2.png');
    Background[3] = loadImage('99_Images/Background_3.png');
    webButtons[0] = new WebButton([20,100],loadImage('99_Images/Gas_Composition_A.jpg'),loadImage('99_Images/Gas_Composition_B.jpg'),loadImage('99_Images/Gas_Composition_C.jpg'));
    webButtons[1] = new WebButton([230,100],loadImage('99_Images/Numerical_Results_A.jpg'),loadImage('99_Images/Numerical_Results_B.jpg'),loadImage('99_Images/Numerical_Results_C.jpg'));
    webButtons[2] = new WebButton([440,100],loadImage('99_Images/Charts_A.jpg'),loadImage('99_Images/Charts_B.jpg'),loadImage('99_Images/Charts_C.jpg'));
    webButtons[3] = new WebButton([20,150],loadImage('99_Images/Manual_Input_A.jpg'),loadImage('99_Images/Manual_Input_B.jpg'),loadImage('99_Images/Manual_Input_C.jpg'));
    webButtons[4] = new WebButton([230,150],loadImage('99_Images/Paste_from_spreadsheet_A.jpg'),loadImage('99_Images/Paste_from_spreadsheet_B.jpg'),loadImage('99_Images/Paste_from_spreadsheet_C.jpg'));
    webButtons[5] = new WebButton([380,620],loadImage('99_Images/Clear_A.jpg'),loadImage('99_Images/Clear_B.jpg'),loadImage('99_Images/Clear_C.jpg'));
    webButtons[6] = new WebButton([430,230],loadImage('99_Images/Update_Gas_Composition_A.jpg'),loadImage('99_Images/Update_Gas_Composition_B.jpg'),loadImage('99_Images/Update_Gas_Composition_C.jpg'));
    webButtons[7] = new WebButton([230,150],loadImage('99_Images/GERG_A.jpg'),loadImage('99_Images/GERG_B.jpg'),loadImage('99_Images/GERG_C.jpg'));
    webButtons[8] = new WebButton([330,150],loadImage('99_Images/DETAIL_A.jpg'),loadImage('99_Images/DETAIL_B.jpg'),loadImage('99_Images/DETAIL_C.jpg'));
    webButtons[10] = new WebButton([440,150],loadImage('99_Images/P_D_A.jpg'),loadImage('99_Images/P_D_B.jpg'),loadImage('99_Images/P_D_C.jpg'));
    webButtons[11] = new WebButton([520,150],loadImage('99_Images/P_V_A.jpg'),loadImage('99_Images/P_V_B.jpg'),loadImage('99_Images/P_V_C.jpg'));
    webButtons[12] = new WebButton([600,150],loadImage('99_Images/P_H_A.jpg'),loadImage('99_Images/P_H_B.jpg'),loadImage('99_Images/P_H_C.jpg'));
    webButtons[13] = new WebButton([680,150],loadImage('99_Images/T_H_A.jpg'),loadImage('99_Images/T_H_B.jpg'),loadImage('99_Images/T_H_C.jpg'));
    webButtons[14] = new WebButton([760,150],loadImage('99_Images/T_S_A.jpg'),loadImage('99_Images/T_S_B.jpg'),loadImage('99_Images/T_S_C.jpg'));
    webButtons[15] = new WebButton([425,150],loadImage('99_Images/GROSS_M1_A.jpg'),loadImage('99_Images/GROSS_M1_B.jpg'),loadImage('99_Images/GROSS_M1_C.jpg'));
    webButtons[16] = new WebButton([560,150],loadImage('99_Images/GROSS_M2_A.jpg'),loadImage('99_Images/GROSS_M2_B.jpg'),loadImage('99_Images/GROSS_M2_C.jpg'));
}
function setup(){
    x[1]=0.94; x[3]=0.05; x[20]=0.01;
    CreateTheXInputs();
    ButtonsConfiguration();
    GERG.Setup();
    Detail.Setup();
    GROSS.Setup();
    createCanvas(1360, 768);
    CreateInputsIn00();
    CreateTheMagicBox();
    SetupTheTextAreaAnimation();
    SetupXsOfDrawing();
    CalculateDrawedData();
}
function ButtonsConfiguration(){
    webButtons[0].brothers = [webButtons[1],webButtons[2]];
    webButtons[0].favoriteSon = webButtons[3];
    webButtons[1].brothers = [webButtons[0],webButtons[2]];
    webButtons[1].favoriteSon = webButtons[7];
    webButtons[2].brothers = [webButtons[0],webButtons[1]];
    webButtons[2].favoriteSon = webButtons[10];
    webButtons[3].brothers = webButtons[4];
    webButtons[3].father = webButtons[0];
    webButtons[4].brothers=webButtons[3];
    webButtons[4].father = webButtons[0];
    webButtons[5].father = webButtons[3];
    webButtons[5].pressAndHold = true;
    webButtons[6].father = webButtons[3];
    webButtons[6].pressAndHold = true;
    webButtons[10].brothers=[webButtons[11],webButtons[12],webButtons[13],webButtons[14]];
    webButtons[10].father = webButtons[2];    
    webButtons[11].brothers=[webButtons[10],webButtons[12],webButtons[13],webButtons[14]];
    webButtons[11].father = webButtons[2];
    webButtons[12].brothers=[webButtons[10],webButtons[11],webButtons[13],webButtons[14]];
    webButtons[12].father = webButtons[2];
    webButtons[13].brothers=[webButtons[10],webButtons[11],webButtons[12],webButtons[14]];
    webButtons[13].father = webButtons[2];    
    webButtons[14].brothers=[webButtons[10],webButtons[11],webButtons[12],webButtons[13]];
    webButtons[14].father = webButtons[2];
    webButtons[7].brothers=[webButtons[8],webButtons[15],webButtons[16]];
    webButtons[7].father = webButtons[1];
    webButtons[8].brothers=[webButtons[7],webButtons[15],webButtons[16]];
    webButtons[8].father = webButtons[1];
    webButtons[15].brothers=[webButtons[7],webButtons[8],webButtons[16]];
    webButtons[15].father = webButtons[1];
    webButtons[16].brothers=[webButtons[7],webButtons[8],webButtons[15]];
    webButtons[16].father = webButtons[1];
    webButtons[5].WhatShouldIDoAfterYouCallMe = function(){
        x=Array(22).fill(0);
        FromXToDOMs();
    }
    webButtons[6].WhatShouldIDoAfterYouCallMe = function(){
        FromDOMsToX();
        FromXToDOMs();
        CalculateDrawedData();
    }
}
function FromDOMsToX(){
    x[1]=UpdateComponent(inpMethane);
    x[2]=UpdateComponent(inpNitrogen);
    x[3]=UpdateComponent(inpCarbonDioxide);
    x[4]=UpdateComponent(inpEthane);
    x[5]=UpdateComponent(inpPropane);
    x[6]=UpdateComponent(inpIsoButane);
    x[7]=UpdateComponent(inpnButane);
    x[8]=UpdateComponent(inpIsopentane);
    x[9]=UpdateComponent(inpnPentane);
    x[10]=UpdateComponent(inpnHexane);
    x[11]=UpdateComponent(inpnHeptane);
    x[12]=UpdateComponent(inpnOctane);
    x[13]=UpdateComponent(inpnNonane);
    x[14]=UpdateComponent(inpnDecane);
    x[15]=UpdateComponent(inpHydrogen);
    x[16]=UpdateComponent(inpOxygen);
    x[17]=UpdateComponent(inpCarbonMonoxide);
    x[18]=UpdateComponent(inpWater);
    x[19]=UpdateComponent(inpHydrogenSulfide);
    x[20]=UpdateComponent(inpHelium);
    x[21]=UpdateComponent(inpArgon);
    //Normalization
    SumOfComponents=0;
    for(let i=1; i <= 21; i++){
        SumOfComponents=SumOfComponents+x[i];
    }
    for(let i=1; i <= 21; i++){
        x[i]=x[i]/SumOfComponents;
    }
}
function UpdateComponent(ComponentOfDOM){
    if(ComponentOfDOM.value()==''){
        return 0;
    }
    return parseFloat(ComponentOfDOM.value());
}
function CreateInputsIn00(){
    let aux=25;
    let InitialX=730;
    inpPressure=createInput(GERG.Pressure.toString());
    inpPressure.size(75,20);
    inpPressure.position(InitialX+95,aux);
    aux=aux+30;

    inpTemperature=createInput(GERG.Temperature.toString());
    inpTemperature.size(75,20);
    inpTemperature.position(InitialX+95,aux);
    aux=aux+30;
}
function mousePressed(){
    if (event.type != 'touchstart') return true;
    webButtons[0].checkIfThisClickIsForMe();
    webButtons[1].checkIfThisClickIsForMe();
    webButtons[2].checkIfThisClickIsForMe();
    webButtons[3].checkIfThisClickIsForMe();
    webButtons[4].checkIfThisClickIsForMe();
    webButtons[5].checkIfThisClickIsForMe();
    webButtons[6].checkIfThisClickIsForMe();
    webButtons[7].checkIfThisClickIsForMe();
    webButtons[8].checkIfThisClickIsForMe();
    webButtons[10].checkIfThisClickIsForMe();
    webButtons[11].checkIfThisClickIsForMe();
    webButtons[12].checkIfThisClickIsForMe();
    webButtons[13].checkIfThisClickIsForMe();
    webButtons[14].checkIfThisClickIsForMe();
    webButtons[15].checkIfThisClickIsForMe();
    webButtons[16].checkIfThisClickIsForMe();
    return false;
}
function draw(){
    background(255);
    TellMeWichScreenAmISeen();
    webButtons[0].drawMe();
    webButtons[1].drawMe();
    webButtons[2].drawMe();
    webButtons[3].drawMe();
    webButtons[4].drawMe();
    webButtons[5].drawMe();
    webButtons[6].drawMe();
    webButtons[7].drawMe();
    webButtons[8].drawMe();
    webButtons[10].drawMe();
    webButtons[11].drawMe();
    webButtons[12].drawMe();
    webButtons[13].drawMe();
    webButtons[14].drawMe();
    webButtons[15].drawMe();
    webButtons[16].drawMe();
}
function TellMeWichScreenAmISeen(){
    if(webButtons[3].activated && webButtons[3].visible){
        image(Background[1],0,0);
        disappearTheDOMs(false);
        disappearTheTextArea(true);
        SumOfComponents = 0;
        SumOfComponents += UpdateComponent(inpMethane);
        SumOfComponents += UpdateComponent(inpNitrogen);
        SumOfComponents += UpdateComponent(inpCarbonDioxide);
        SumOfComponents += UpdateComponent(inpEthane);
        SumOfComponents += UpdateComponent(inpPropane);
        SumOfComponents += UpdateComponent(inpIsoButane);
        SumOfComponents += UpdateComponent(inpnButane);
        SumOfComponents += UpdateComponent(inpIsopentane);
        SumOfComponents += UpdateComponent(inpnPentane);
        SumOfComponents += UpdateComponent(inpnHexane);
        SumOfComponents += UpdateComponent(inpnHeptane);
        SumOfComponents += UpdateComponent(inpnOctane);
        SumOfComponents += UpdateComponent(inpnNonane);
        SumOfComponents += UpdateComponent(inpnDecane);
        SumOfComponents += UpdateComponent(inpHydrogen);
        SumOfComponents += UpdateComponent(inpOxygen);
        SumOfComponents += UpdateComponent(inpCarbonMonoxide);
        SumOfComponents += UpdateComponent(inpWater);
        SumOfComponents += UpdateComponent(inpHydrogenSulfide);
        SumOfComponents += UpdateComponent(inpHelium);
        SumOfComponents += UpdateComponent(inpArgon);
        push();
        textSize(25);
        textStyle(BOLD);
        fill(CanvasLeterColor);
        if(SumOfComponents < 1.25){
        text(SumOfComponents.toFixed(3),575,674);
        }else{text(SumOfComponents.toFixed(1),575,674);}
        pop();
        return;
    }
    if(webButtons[4].activated && webButtons[4].visible){
        image(Background[2],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(false);
        CreateTheAnimation();
        return;
    }
    if(webButtons[7].activated && webButtons[7].visible){
        image(Background[0],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        RunGERG2008();
        DrawGERGResults();
        return;
    }
    if(webButtons[8].activated && webButtons[8].visible){
        image(Background[0],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        RunDetail();
        DrawDetailResults();
        return;
    }
    if(webButtons[10].activated && webButtons[10].visible){
        image(Background[3],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        DrawPD();
        FindTheClickedPointPD();
        return;
    }
    if(webButtons[11].activated && webButtons[11].visible){
        image(Background[3],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        DrawPV();
        FindTheClickedPointPV();
        return;
    }
    if(webButtons[12].activated && webButtons[12].visible){
        image(Background[3],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        DrawPH();
        FindTheClickedPointPH();
        return;
    }
    if(webButtons[13].activated && webButtons[13].visible){
        image(Background[3],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        DrawTH();
        FindTheClickedPointTH();
        return;
    }
    if(webButtons[14].activated && webButtons[14].visible){
        image(Background[3],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        DrawTS();
        FindTheClickedPointTS();
        return;
    }
    if(webButtons[15].activated && webButtons[15].visible){
        image(Background[0],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        RunGROSS_Method1();
        DrawGrossResults();
        return;
    }
    if(webButtons[16].activated && webButtons[16].visible){
        image(Background[0],0,0);
        disappearTheDOMs(true);
        disappearTheTextArea(true);
        RunGROSS_Method2();
        DrawGrossResults();
        return;
    }
    disappearTheDOMs(true);
    disappearTheTextArea(true);
    image(Background[0],0,0);
}
function RunGERG2008(){
    UploadTheInputs();
    GERG.CalculateDensity(iFlag,GERG.Temperature,GERG.Pressure,x);
}
function RunGROSS_Method1(){
    UploadTheInputs();
    GROSS.CalculateInputs(GROSS.Temperature,GROSS.Pressure,x);
    GROSS.Pd = GROSS.Pressure;
    GROSS.Hv = GROSS.HN;
    GROSS.Method1(GROSS.Th,GROSS.Td,GROSS.Pd,GROSS.xGrs,GROSS.Gr,GROSS.Hv);
}
function RunGROSS_Method2(){
    UploadTheInputs();
    GROSS.CalculateInputs(GROSS.Temperature,GROSS.Pressure,x);
    GROSS.Pd = GROSS.Pressure;
    GROSS.Hv = GROSS.HN;
    GROSS.Method2(GROSS.Th,GROSS.Td,GROSS.Pd,GROSS.xGrs,GROSS.Gr);
}
function RunDetail(){
    UploadTheInputs();
    Detail.DensityDetail(Detail.Temperature,Detail.Pressure,x);
    Detail.PropertiesDetail(Detail.Temperature,Detail.Density,x);
}
function UploadTheInputs(){
    GERG.Pressure=parseFloat(inpPressure.value());
    Detail.Pressure=parseFloat(inpPressure.value());
    GROSS.Pressure=parseFloat(inpPressure.value());
    
    GERG.Temperature=parseFloat(inpTemperature.value());
    Detail.Temperature=parseFloat(inpTemperature.value());
    GROSS.Temperature=parseFloat(inpTemperature.value());
    FromDOMsToX();
    FromXToDOMs();
}
function DrawGERGResults(){
    let PositionOfGERGColumn=50;
    let aux=250;
    push();
    textSize(25);
    textStyle(BOLD);
    fill(CanvasLeterColor);
    text('GERG 2008',PositionOfGERGColumn,aux);
    textSize(20);
    textFont('Georgia');
    textStyle(NORMAL);
    aux=aux+30;
    fill(CanvasLeterColor);
    text('Molar Mass: '+ GERG.MolarMass.toFixed(2) + ' g/mol',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Density: '+ GERG.Density.toFixed(3) + ' mol/l',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Compressibility Factor: '+ GERG.CompressibilityFactor.toFixed(2),PositionOfGERGColumn,aux);
    aux=aux+25;
    text('dPdD: '+ GERG.dPdD.toFixed(0) + ' kPa/(mol/l)',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('dPdT: '+ GERG.dPdT.toFixed(2) + ' kPa/K',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Internal Energy: '+ GERG.U.toFixed(1) + ' J/mol',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Entalphy: '+ GERG.H.toFixed(1) + ' J/mol',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Entropy: '+ GERG.S.toFixed(1) + ' J/mol',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Cv: '+ GERG.Cv.toFixed(3) + ' J/(mol-K)',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Cp: '+ GERG.Cp.toFixed(3) + ' J/(mol-K)',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Speed Of Sound: '+ GERG.SpeedOfSound.toFixed(1) + ' (m/s)',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Gibbs Free Energy: '+ GERG.G.toFixed(1) + ' (J/mol)',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Joule Thomson: '+ GERG.JouleThomson.toFixed(3) + ' (K/kPa)',PositionOfGERGColumn,aux);
    if(GERG.ierr>0 || Detail.ierr>0){
        aux=aux+25;
        text('Errors Found: '+ GERG.herr,PositionOfGERGColumn,aux);
    }
    pop();
}
function DrawDetailResults(){
    let PositionOfDetailColumn=50;
    let aux=250;
    push();
    textSize(25);
    textStyle(BOLD);
    fill(CanvasLeterColor);
    text('DETAIL',PositionOfDetailColumn,aux);
    textSize(20);
    textFont('Georgia');
    textStyle(NORMAL);
    aux=aux+30;
    fill(CanvasLeterColor);
    text('Molar Mass: '+ Detail.MolarMass.toFixed(2) + ' g/mol',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Density: '+ Detail.Density.toFixed(3) + ' mol/l',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Compressibility Factor: '+ Detail.CompressibilityFactor.toFixed(2),PositionOfDetailColumn,aux);
    aux=aux+25;
    text('dPdD: '+ Detail.dPdD.toFixed(0) + ' kPa/(mol/l)',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('dPdT: '+ Detail.dPdT.toFixed(2) + ' kPa/K',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Internal Energy: '+ Detail.U.toFixed(1) + ' J/mol',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Entalphy: '+ Detail.H.toFixed(1) + ' J/mol',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Entropy: '+ Detail.S.toFixed(1) + ' J/mol',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Cv: '+ Detail.Cv.toFixed(3) + ' J/(mol-K)',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Cp: '+ Detail.Cp.toFixed(3) + ' J/(mol-K)',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Speed Of Sound: '+ Detail.SpeedOfSound.toFixed(1) + ' (m/s)',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Gibbs Free Energy: '+ Detail.G.toFixed(1) + ' (J/mol)',PositionOfDetailColumn,aux);
    aux=aux+25;
    text('Joule Thomson: '+ Detail.JouleThomson.toFixed(3) + ' (K/kPa)',PositionOfDetailColumn,aux);
    if(Detail.ierr>0){
        aux=aux+25;
        text('Errors Found: '+ Detail.herr,PositionOfDetailColumn,aux);
    }
    pop();
}
function DrawGrossResults(){
    let PositionOfGrossColumn=50;
    let aux=250;
    push();
    textSize(25);
    textStyle(BOLD);
    fill(CanvasLeterColor);
    text('GROSS',PositionOfGrossColumn,aux);
    textSize(20);
    textFont('Georgia');
    textStyle(NORMAL);
    aux=aux+30;
    fill(CanvasLeterColor);
    text('Molar Mass: '+ GROSS.MolarMass.toFixed(2) + ' g/mol',PositionOfGrossColumn,aux);
    aux=aux+25;
    text('Density: '+ GROSS.Density.toFixed(3) + ' mol/l',PositionOfGrossColumn,aux);
    aux=aux+25;
    text('Compressibility Factor: '+ GROSS.CompressibilityFactor.toFixed(2), PositionOfGrossColumn, aux);
    aux=aux+25;
    text('dPdD: '+ GROSS.dPdD.toFixed(0) + ' kPa/(mol/l)',PositionOfGrossColumn,aux);
    aux=aux+25;
    text('Relative Density: '+ GROSS.Gr.toFixed(3),PositionOfGrossColumn,aux);
    aux=aux+25;
    text('Volumetric Heating Value: '+ GROSS.Hv.toFixed(3) + ' kJ/mol',PositionOfGrossColumn,aux);
    aux=aux+25;    
    text('Compressibility Factor: '+ GROSS.CompressibilityFactor.toFixed(2),PositionOfGrossColumn,aux);
    if(GROSS.ierr>0){
        aux=aux+25;
        text('Errors Found: '+ GROSS.herr,PositionOfGrossColumn,aux);
    }
    pop();
}
function FromXToDOMs(){
    inpMethane.value((x[1]*100).toString());
    inpNitrogen.value((x[2]*100).toString());
    inpCarbonDioxide.value((x[3]*100).toString());
    inpEthane.value((x[4]*100).toString());
    inpPropane.value((x[5]*100).toString());
    inpIsoButane.value((x[6]*100).toString());
    inpnButane.value((x[7]*100).toString());
    inpIsopentane.value((x[8]*100).toString());    
    inpnPentane.value((x[9]*100).toString());
    inpnHexane.value((x[10]*100).toString());
    inpnHeptane.value((x[11]*100).toString());
    inpnOctane.value((x[12]*100).toString());
    inpnNonane.value((x[13]*100).toString());
    inpnDecane.value((x[14]*100).toString());
    inpHydrogen.value((x[15]*100).toString());
    inpOxygen.value((x[16]*100).toString());
    inpCarbonMonoxide.value((x[17]*100).toString());
    inpWater.value((x[18]*100).toString());
    inpHydrogenSulfide.value((x[19]*100).toString());
    inpHelium.value((x[20]*100).toString());
    inpArgon.value((x[21]*100).toString());
}
function disappearTheTextArea(trueforyes){
    let aux;
    if (trueforyes){aux='hidden'}else{aux='visible'}
    InputFromXLS.elt.style.visibility=aux;
}
function disappearTheDOMs(trueforyes){
    let aux;
    if (trueforyes){aux='hidden'}else{aux='visible'}
    inpMethane.elt.style.visibility=aux;
    inpNitrogen.elt.style.visibility=aux;
    inpCarbonDioxide.elt.style.visibility=aux;
    inpEthane.elt.style.visibility=aux;
    inpPropane.elt.style.visibility=aux;
    inpIsoButane.elt.style.visibility=aux;
    inpnButane.elt.style.visibility=aux;
    inpIsopentane.elt.style.visibility=aux;    
    inpnPentane.elt.style.visibility=aux;
    inpnHexane.elt.style.visibility=aux;
    inpnHeptane.elt.style.visibility=aux;
    inpnOctane.elt.style.visibility=aux;
    inpnNonane.elt.style.visibility=aux;
    inpnDecane.elt.style.visibility=aux;
    inpHydrogen.elt.style.visibility=aux;
    inpOxygen.elt.style.visibility=aux;
    inpCarbonMonoxide.elt.style.visibility=aux;
    inpWater.elt.style.visibility=aux;
    inpHydrogenSulfide.elt.style.visibility=aux;
    inpHelium.elt.style.visibility=aux;
    inpArgon.elt.style.visibility=aux;
}
function CreateTheXInputs(){
    let InitialX=240;
    let InitialY=225;
    let SeparationX=0;
    let SeparationY=23.75;
    let SizeOfInput=[31,13];
    let aux=[InitialX,InitialY];

    inpMethane=createInput((x[1]*100).toString());          //1 - Methane
    inpMethane.size(SizeOfInput[0],SizeOfInput[1]);
    inpMethane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpNitrogen=createInput((x[2]*100).toString());         //2 - Nitrogen
    inpNitrogen.size(SizeOfInput[0],SizeOfInput[1]);
    inpNitrogen.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;   

    inpCarbonDioxide=createInput((x[3]*100).toString());    //3 - CarbonDioxide
    inpCarbonDioxide.size(SizeOfInput[0],SizeOfInput[1]);
    inpCarbonDioxide.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpEthane=createInput((x[4]*100).toString());           //4 - Ethane
    inpEthane.size(SizeOfInput[0],SizeOfInput[1]);
    inpEthane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpPropane=createInput((x[5]*100).toString());          //5 - Propane
    inpPropane.size(SizeOfInput[0],SizeOfInput[1]);
    inpPropane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpIsoButane=createInput((x[6]*100).toString());        //6 - IsoButane
    inpIsoButane.size(SizeOfInput[0],SizeOfInput[1]);
    inpIsoButane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpnButane=createInput((x[7]*100).toString());          //7 - nButane
    inpnButane.size(SizeOfInput[0],SizeOfInput[1]);
    inpnButane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpIsopentane=createInput((x[8]*100).toString());       //8 - Isopentane
    inpIsopentane.size(SizeOfInput[0],SizeOfInput[1]);
    inpIsopentane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnPentane=createInput((x[9]*100).toString());         //9 - nPentane
    inpnPentane.size(SizeOfInput[0],SizeOfInput[1]);
    inpnPentane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnHexane=createInput((x[10]*100).toString());         //10 - nHexane
    inpnHexane.size(SizeOfInput[0],SizeOfInput[1]);
    inpnHexane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnHeptane=createInput((x[11]*100).toString());        //11 - nHeptane
    inpnHeptane.size(SizeOfInput[0],SizeOfInput[1]);
    inpnHeptane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnOctane=createInput((x[12]*100).toString());         //12 - nOctane
    inpnOctane.size(SizeOfInput[0],SizeOfInput[1]);
    inpnOctane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnNonane=createInput((x[13]*100).toString());         //13 - nNonane
    inpnNonane.size(SizeOfInput[0],SizeOfInput[1]);
    inpnNonane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnDecane=createInput((x[14]*100).toString());         //14 - nDecane
    inpnDecane.size(SizeOfInput[0],SizeOfInput[1]);
    inpnDecane.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpHydrogen=createInput((x[15]*100).toString());        //15 - Hydrogen
    inpHydrogen.size(SizeOfInput[0],SizeOfInput[1]);
    inpHydrogen.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpOxygen=createInput((x[16]*100).toString());          //16 - Oxygen
    inpOxygen.size(SizeOfInput[0],SizeOfInput[1]);
    inpOxygen.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpCarbonMonoxide=createInput((x[17]*100).toString());  //17 - CarbonMonoxide
    inpCarbonMonoxide.size(SizeOfInput[0],SizeOfInput[1]);
    inpCarbonMonoxide.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpWater=createInput((x[18]*100).toString());           //18 - Water
    inpWater.size(SizeOfInput[0],SizeOfInput[1]);
    inpWater.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpHydrogenSulfide=createInput((x[19]*100).toString()); //19 - HydrogenSulfide
    inpHydrogenSulfide.size(SizeOfInput[0],SizeOfInput[1]);
    inpHydrogenSulfide.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpHelium=createInput((x[20]*100).toString());          //20 - Helium
    inpHelium.size(SizeOfInput[0],SizeOfInput[1]);
    inpHelium.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpArgon=createInput((x[21]*100).toString());           //21 - Argon
    inpArgon.size(SizeOfInput[0],SizeOfInput[1]);
    inpArgon.position(aux[0],aux[1]);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
}
class WebButton {
    constructor(position, picture_standby, picture_mouseover, picture_pressed) {
        this.position=position;
        this.height = 0;
        this.width = 0;
        this.picture_standby = picture_standby;
        this.picture_mouseover = picture_mouseover;
        this.picture_pressed = picture_pressed;
        this.visible = true;
        this.activated = false;
        this.brothers = null;
        this.father = null;
        this.pressAndHold = false;
        this.favoriteSon = null;
        this.WhatShouldIDoAfterYouCallMe = null;
    }
    shouldIBeVisible(){
        if(this.father != null){
            if(this.father.activated && this.father.visible){
                this.visible=true;
                return;
            }
            this.visible=false;
        }
    }
    checkIfThisClickIsForMe(){
        if(mouseX > this.position[0] && mouseX < this.position[0] + this.width){
            if(mouseY > this.position[1] && mouseY < this.position[1] + this.height){
                if (Array.isArray(this.brothers)){
                    for(let i = 0; i < this.brothers.length; i++){
                        this.brothers[i].activated=false;
                    }
                }else if(this.brothers != null){this.brothers.activated=false;}
                this.activated = !this.activated;
                this.activateMyFavoriteSon();
                if(this.WhatShouldIDoAfterYouCallMe != null){this.WhatShouldIDoAfterYouCallMe()}
            }
        }
    }
    activateMyFavoriteSon(){
        if (this.favoriteSon != null && this.activated == true){
            this.favoriteSon.activated=true;
            this.ShutUpMyNonFavoriteBrothers();
        }
    }
    ShutUpMyNonFavoriteBrothers(){
        if (Array.isArray(this.favoriteSon.brothers)){
            for(let i = 0; i < this.favoriteSon.brothers.length; i++){
                this.favoriteSon.brothers[i].activated=false;
            }
        return;
        }
        if(this.favoriteSon.brothers != null){
            this.favoriteSon.brothers.activated=false;
            return;
        }
    }
    drawMe(){
        if(this.pressAndHold){this.activated=false}
        this.shouldIBeVisible();
        if (this.visible){
            this.height = this.picture_standby.height;
            this.width = this.picture_standby.width;
            if (this.activated==true){image(this.picture_pressed, this.position[0], this.position[1]);return}
            if(mouseX > this.position[0] && mouseX < this.position[0] + this.width){
                if(mouseY > this.position[1] && mouseY < this.position[1] + this.height){
                    if (mouseIsPressed){
                        image(this.picture_pressed, this.position[0], this.position[1]);return;                        
                    }
                    image(this.picture_mouseover, this.position[0], this.position[1]);return;
                }
            }
            image(this.picture_standby, this.position[0], this.position[1]);
        }
    }
}
