//Globals variables of this page
let CalculateButton;
let ClearButton;
let RadioOfTheChart;
let PDSelectedByMouse=Array(2).fill(0);
let itau=1;
let idel=0;
let ar=zeros([3,3]);
let iFlag=1;
let logo;
const CanvasLeterColor=[0,0,0];
const TextColor='Black';
const DotColor=[200,0,0];
let FuelGas={CalorificValue:0,AirFuelRelationship:0,Density:0};
let Zone0={//Zone of the input composition
    minX:0,maxX:300,minY:210,maxY:720,
}
let Zone00={//Zone of the other configurations
    minX:310,maxX:800,minY:0,maxY:185,
}
let Zone1={//Zone of the written results
    minX:300,maxX:800,minY:220,maxY:460,
}
let Zone2={//Zone of the Drawings
    minX:300,maxX:800,minY:465,maxY:710,
}
let Drawing={
    array:{x:0,y:0},
    P:{Max:2000, Min:50, Current:30, Old:30, PrintedCurrent:0, PrintedOld:0},
    T:{Max:473.15, Min:250, Current:200, Old:200, PrintedCurrent:0, PrintedOld:0},
    D:{Max:0, Min:0, Current:0, Old:0, PrintedCurrent:0, PrintedOld:0},
    ErrorHandling:{ierr:0, herr:''},
    minX:0,maxX:300,minY:200,maxY:800,
    IsBackgroundAlreadyDrawn:false,
}
//
function preload(){logo = loadImage("logo.png")}
function setup(){
    GERG.Setup();
    Detail.Setup();
    createCanvas(860, 1800);
    //createCanvas(window.innerWidth, window.innerHeight);
    x[1]=0.94; x[3]=0.05; x[20]=0.01;
    CreateInputsIn00();
    CreateTheRadio();
    CreateTheXInputs();
    CalculateGERG2008();
    CreateTheMagicBox();
}
function CreateTheMagicBox(){
    InputFromXLS.InputTextArea=select('#PasteXLS');
    InputFromXLS.InputTextArea.input(InputIsActivated);
    InputFromXLS.InputTextArea.position(670,40);
    push();
    createP('You can paste the').position(540,32).style('font-size', '10px');
    createP('chromatography from your').position(540,43).style('font-size', '10px');
    createP('spreadsheet in here.').position(540,54).style('font-size', '10px');
    createP('2 rows or columns').position(540,65).style('font-size', '10px');
    createP('1st the labels').position(540,76).style('font-size', '10px');
    createP('2nd the compositions').position(540,87).style('font-size', '10px');
    createP('several aliases supported').position(540,98).style('font-size', '10px');
    pop();
}
function CreateTheRadio(){
    RadioOfTheChart = createRadio();
    RadioOfTheChart.option('');
    RadioOfTheChart.selected('');
    //RadioOfTheChart.disable(true);
    RadioOfTheChart.position(100,100);
}
function CreateInputsIn00(){
    let aux=15;
    CalculateButton = createButton('Calculate');
    CalculateButton.position(Zone00.minX, Zone00.minY+ aux);
    CalculateButton.size(150,23);
    CalculateButton.mousePressed(CalculateGERG2008);
    aux=aux+30;

    ClearButton = createButton('Clear chromatography');
    ClearButton.position(Zone00.minX, Zone00.minY+ aux);
    ClearButton.size(150,23);
    ClearButton.mousePressed(ClearInputX);
    aux=aux+30;

    inpPressure=createInput(GERG.Pressure.toString());
    inpPressure.size(47,13);
    inpPressure.position(Zone00.minX+95,aux);
    createP('Pressure: ').position(Zone00.minX,aux-13).style('color:'+TextColor);
    createP(' kPa').position(Zone00.minX+165,aux-13).style('color:'+TextColor);
    aux=aux+30;

    inpTemperature=createInput(GERG.Temperature.toString());
    inpTemperature.size(47,13);
    inpTemperature.position(Zone00.minX+95,aux);
    createP('Temperature: ').position(Zone00.minX,aux-13).style('color:'+TextColor);
    createP('Kelvin').position(Zone00.minX+165,aux-13).style('color:'+TextColor);
    aux=aux+30;

    function ClearInputX(){
        x=Array(22).fill(0);
        FromXToDOMs();
    }
}
function BoundaryOfDrawing(){
    //Find the smallest and biggest value of D
    [Drawing.D.Max,Drawing.ErrorHandling.ierr,Drawing.ErrorHandling.herr]=GERG.CalculateDensity(1,Drawing.T.Min,Drawing.P.Max,x);
    [Drawing.D.Min,Drawing.ErrorHandling.ierr,Drawing.ErrorHandling.herr]=GERG.CalculateDensity(1,Drawing.T.Max,Drawing.P.Min,x);
}
function RunGERG2008(){
    [GERG.Density,GERG.ierr,GERG.herr]=GERG.CalculateDensity(iFlag,GERG.Temperature,GERG.Pressure,x);
    [GERG.MolarMass,GERG.Pressure,GERG.CompressibilityFactor,GERG.dPdD,GERG.d2PdD2,GERG.d2PdTD,GERG.dPdT,GERG.U,GERG.H,GERG.S,GERG.Cv,GERG.Cp,GERG.SpeedOfSound,GERG.G,GERG.JouleThomson,GERG.Kappa,GERG.A]=GERG.CalculateProperties(GERG.Temperature,GERG.Density,x);
}
function RunDetail(){
    [Detail.Density,Detail.ierr,Detail.herr]=Detail.DensityDetail(Detail.Temperature,Detail.Pressure,x);
    [Detail.MolarMass,Detail.Pressure,Detail.CompressibilityFactor,Detail.dPdD,Detail.d2PdD2,Detail.d2PdTD,Detail.dPdT,Detail.U,Detail.H,Detail.S,Detail.Cv,Detail.Cp,Detail.SpeedOfSound,Detail.G,Detail.JouleThomson,Detail.Kappa,Detail.A]=Detail.PropertiesDetail(Detail.Temperature,Detail.Density,x);
}
function mouseMoved() {
    if(mouseX < Zone2.maxX && mouseY < Zone2.maxY && mouseX > Zone2.minX && mouseY > Zone2.minY){
        PDSelectedByMouse[0]=map(mouseY,Zone2.maxY,Zone2.minY,Drawing.P.Min,Drawing.P.Max);
        PDSelectedByMouse[1]=map(mouseX,Zone2.minX,Zone2.maxX,Drawing.D.Min,Drawing.D.Max);
        //Estaría Bueno mostrarlo en algún lado
    }
}
function mousePressed(){
    if(mouseX < Zone2.maxX && mouseY < Zone2.maxY && mouseX > Zone2.minX && mouseY > Zone2.minY){
        inpPressure.value(PDSelectedByMouse[0]);
        let DesiredDensity=PDSelectedByMouse[1];
        //Start Binary Search
        let TemperatureUp=Drawing.T.Max;
        let DensityUp=0;
        [DensityUp,GERG.ierr,GERG.herr]=GERG.CalculateDensity(iFlag,TemperatureUp,inpPressure.value(),x);
        let TemperatureDown=Drawing.T.Min;
        let DensityDown=0;
        [DensityDown,GERG.ierr,GERG.herr]=GERG.CalculateDensity(iFlag,TemperatureDown,inpPressure.value(),x);
        let TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
        let DensityMiddle=0;
        for(let i=0; i<=25; i++){
            [DensityMiddle,GERG.ierr,GERG.herr]=GERG.CalculateDensity(iFlag,TemperatureMiddle,inpPressure.value(),x);
            if (DesiredDensity < DensityMiddle){
                //TemperatureUp=TemperatureUp;
                TemperatureDown=TemperatureMiddle;
                TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
            }else{
                TemperatureUp=TemperatureMiddle;
                //TemperatureDown=TemperatureDown;
                TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
            }
        }
        inpTemperature.value(TemperatureMiddle);
        CalculateGERG2008();
    }
}
function draw(){
    if(Drawing.IsBackgroundAlreadyDrawn==false){
        clear();
        //Main Framework
        push();
        noStroke();
        fill(100,100,100,5);
        rect(0,0,Zone00.maxX,Zone0.maxY,0,65,65,65);
        rect(0,0,Zone00.maxX+5,Zone0.maxY+5,0,65,65,65);
        rect(0,0,Zone00.maxX+10,Zone0.maxY+10,0,65,65,65);
        rect(0,0,Zone00.maxX+15,Zone0.maxY+15,0,65,65,65);
        rect(0,0,Zone00.maxX+20,Zone0.maxY+20,0,65,65,65);
        rect(0,0,Zone00.maxX+25,Zone0.maxY+25,0,65,65,65);
        rect(0,0,Zone00.maxX+30,Zone0.maxY+30,0,65,65,65);
        rect(0,0,Zone00.maxX+35,Zone0.maxY+35,0,65,65,65);
        rect(0,0,Zone00.maxX+40,Zone0.maxY+40,0,65,65,65);
        rect(0,0,Zone00.maxX+45,Zone0.maxY+45,0,65,65,65);
        rect(0,0,Zone00.maxX+50,Zone0.maxY+50,0,65,65,65);
        rect(0,0,Zone00.maxX+55,Zone0.maxY+55,0,65,65,65);
        pop();
        //Lines
        push();
        strokeWeight(0.1);
        for(let i=0; i <= 60; i++){
            stroke(random(225,255),random(230,200),random(230,200));
            line(Zone0.maxX-random(5,35),Zone00.maxY,Zone0.maxX-random(17.5,22.5),Zone0.maxY);
            stroke(random(215,255),random(215,255),0,150);
            line(Zone1.minX,Zone1.maxY-5,Zone1.minX + (Zone1.maxX-Zone1.minX)/2,Zone1.maxY+random(-15,5));
            line(Zone1.minX + (Zone1.maxX-Zone1.minX)/2,Zone1.maxY+random(-15,5),Zone1.maxX,Zone1.maxY-5);
        }
        pop();
        //Upper Banner
        push();
        noStroke();
        //fill(174,105,240,10);
        fill(255,215,215,10);
        rect(0,0,Zone00.maxX,Zone00.maxY,85,0,65,65);
        rect(0,0,Zone00.maxX-5,Zone00.maxY+1,85,0,65,65);
        rect(0,0,Zone00.maxX-10,Zone00.maxY+3,85,0,65,65);
        rect(0,0,Zone00.maxX-15,Zone00.maxY+5,85,0,65,65);
        rect(0,0,Zone00.maxX-20,Zone00.maxY+7,85,0,65,65);
        rect(0,0,Zone00.maxX-25,Zone00.maxY+9,85,0,65,65);
        rect(0,0,Zone00.maxX-30,Zone00.maxY+11,85,0,65,65);
        rect(0,0,Zone00.maxX-35,Zone00.maxY+13,85,0,65,65);
        pop();
        //logo
        image(logo, 0, 0);
        //
        text('Pressure: '+ Drawing.P.Max.toFixed(0) + ' kPa', Zone2.minX+20, Zone2.minY+20);
        text('Density: '+ Drawing.D.Max.toFixed(2) + 'mol/l', Zone2.maxX-120, Zone2.maxY-20);    
        DrawGERGResults();
        Drawing.IsBackgroundAlreadyDrawn=true;
    }
    //Zone Zero -> Where the numerical Composition is Asked
    //Zone Zero Zero -> Where the parameters are seted
    //Zone I -> Where the numerical results are shown
    //Zone II -> Where the Chart is shown results are shown
    //push();
    //stroke(DotColor);
    //strokeWeight(10);
    //point(map(GERG.Density,Drawing.D.Min,Drawing.D.Max,Zone2.minX,Zone2.maxX),map(GERG.Pressure,Drawing.P.Min,Drawing.P.Max,Zone2.maxY,Zone2.minY));
    //pop();
    RadioOfTheChart.position(map(GERG.Density,Drawing.D.Min,Drawing.D.Max,Zone2.minX,Zone2.maxX)-3.5,map(GERG.Pressure,Drawing.P.Min,Drawing.P.Max,Zone2.maxY,Zone2.minY)-1);
    if(Drawing.T.Current<Drawing.T.Max){
        Drawing.P.Current=Drawing.P.Current+10;
        [Drawing.D.Current,Drawing.ErrorHandling.ierr,Drawing.ErrorHandling.herr]=GERG.CalculateDensity(1,Drawing.T.Current,Drawing.P.Current,x);
        Drawing.P.PrintedOld=map(Drawing.P.Old,Drawing.P.Min,Drawing.P.Max,Zone2.maxY,Zone2.minY);
        Drawing.T.PrintedOld=map(Drawing.T.Old,Drawing.T.Min,Drawing.T.Max,Zone2.maxY,Zone2.minY);
        Drawing.D.PrintedOld=map(Drawing.D.Old,Drawing.D.Min,Drawing.D.Max,Zone2.minX,Zone2.maxX);
        Drawing.P.PrintedCurrent=map(Drawing.P.Current,Drawing.P.Min,Drawing.P.Max,Zone2.maxY,Zone2.minY);
        Drawing.T.PrintedCurrent=map(Drawing.T.Current,Drawing.T.Min,Drawing.T.Max,Zone2.maxY,Zone2.minY);
        Drawing.D.PrintedCurrent=map(Drawing.D.Current,Drawing.D.Min,Drawing.D.Max,Zone2.minX,Zone2.maxX);
        if(Drawing.P.Current>=Drawing.P.Max){
            Drawing.T.Current=Drawing.T.Current+15;
            Drawing.P.Current=Drawing.P.Min;
            Drawing.P.Old=Drawing.P.Min;
            Drawing.D.Old=Drawing.D.Min;
        }else{
            if(Drawing.ErrorHandling.ierr == 0){
                line(Drawing.D.PrintedCurrent,Drawing.P.PrintedCurrent,Drawing.D.PrintedOld,Drawing.P.PrintedOld);
                Drawing.P.Old=Drawing.P.Current;
                Drawing.D.Old=Drawing.D.Current;
            }else{
                console.log(Drawing.ErrorHandling.herr);
            }
        }
    }
}
function DrawGERGResults(){
    let PositionOfGERGColumn=Zone1.minX;
    let PositionOfDetailColumn=Zone1.minX+1/2*(Zone1.maxX-Zone1.minX);
    Drawing.P.Current=Drawing.P.Min;
    Drawing.P.Old=Drawing.P.Min;
    Drawing.D.Old=Drawing.D.Min;
    push();
    textSize(20);
    textStyle(BOLD);
    fill(CanvasLeterColor);
    text('GERG 2008',PositionOfGERGColumn,Zone1.minY);
    text('DETAIL',PositionOfDetailColumn,Zone1.minY);
    pop();
    textSize(14);
    textStyle(NORMAL);
    let aux=Zone1.minY+30;
    fill(CanvasLeterColor);
    text('Molar Mass: '+ GERG.MolarMass.toFixed(2) + ' g/mol',PositionOfGERGColumn,aux);
    text('Molar Mass: '+ Detail.MolarMass.toFixed(2) + ' g/mol',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Density: '+ GERG.Density.toFixed(3) + ' mol/l',PositionOfGERGColumn,aux);
    text('Density: '+ Detail.Density.toFixed(3) + ' mol/l',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Compressibility Factor: '+ GERG.CompressibilityFactor.toFixed(2),PositionOfGERGColumn,aux);
    text('Compressibility Factor: '+ Detail.CompressibilityFactor.toFixed(2),PositionOfDetailColumn,aux);
    aux=aux+15;
    text('dPdD: '+ GERG.dPdD.toFixed(0) + ' kPa/(mol/l)',PositionOfGERGColumn,aux);
    text('dPdD: '+ Detail.dPdD.toFixed(0) + ' kPa/(mol/l)',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('dPdT: '+ GERG.dPdT.toFixed(2) + ' kPa/K',PositionOfGERGColumn,aux);
    text('dPdT: '+ Detail.dPdT.toFixed(2) + ' kPa/K',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Internal Energy: '+ GERG.U.toFixed(1) + ' J/mol',PositionOfGERGColumn,aux);
    text('Internal Energy: '+ Detail.U.toFixed(1) + ' J/mol',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Entalphy: '+ GERG.H.toFixed(1) + ' J/mol',PositionOfGERGColumn,aux);
    text('Entalphy: '+ Detail.H.toFixed(1) + ' J/mol',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Entropy: '+ GERG.S.toFixed(1) + ' J/mol',PositionOfGERGColumn,aux);
    text('Entropy: '+ Detail.S.toFixed(1) + ' J/mol',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Cv: '+ GERG.Cv.toFixed(3) + ' J/(mol-K)',PositionOfGERGColumn,aux);
    text('Cv: '+ Detail.Cv.toFixed(3) + ' J/(mol-K)',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Cp: '+ GERG.Cp.toFixed(3) + ' J/(mol-K)',PositionOfGERGColumn,aux);
    text('Cp: '+ Detail.Cp.toFixed(3) + ' J/(mol-K)',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Speed Of Sound: '+ GERG.SpeedOfSound.toFixed(1) + ' (m/s)',PositionOfGERGColumn,aux);
    text('Speed Of Sound: '+ Detail.SpeedOfSound.toFixed(1) + ' (m/s)',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Gibbs Free Energy: '+ GERG.G.toFixed(1) + ' (J/mol)',PositionOfGERGColumn,aux);
    text('Gibbs Free Energy: '+ Detail.G.toFixed(1) + ' (J/mol)',PositionOfDetailColumn,aux);
    aux=aux+15;
    text('Joule Thomson: '+ GERG.JouleThomson.toFixed(3) + ' (K/kPa)',PositionOfGERGColumn,aux);
    text('Joule Thomson: '+ Detail.JouleThomson.toFixed(3) + ' (K/kPa)',PositionOfDetailColumn,aux);
    if(GERG.ierr>0 || Detail.ierr>0){
        aux=aux+15;
        text('Errors Found: '+ GERG.herr,PositionOfGERGColumn,aux);
        text('Errors Found: '+ Detail.herr,PositionOfDetailColumn,aux);
    }
}
function CalculateGERG2008(){
    UploadTheInputs();
    RunGERG2008();
    RunDetail();
    BoundaryOfDrawing();
    Drawing.T.Current=Drawing.T.Min;
    Drawing.P.Current=Drawing.P.Min;
    function UploadTheInputs(){
        GERG.Pressure=parseFloat(inpPressure.value());
        Detail.Pressure=parseFloat(inpPressure.value());
        GERG.Temperature=parseFloat(inpTemperature.value());
        Detail.Temperature=parseFloat(inpTemperature.value());
        FromDOMsToX();
        NormalizeX();
        FromXToDOMs();
    }
    Drawing.IsBackgroundAlreadyDrawn=false;
}
function NormalizeX(){
    let SumOfComponents=0;
    for(let i=1; i <= 21; i++){
        SumOfComponents=SumOfComponents+x[i];
    }
    for(let i=1; i <= 21; i++){
        x[i]=x[i]/SumOfComponents;
    }
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
    function UpdateComponent(ComponentOfDOM){
        if(ComponentOfDOM.value()==''){
            return 0;
        }
        return parseFloat(ComponentOfDOM.value())/100;
    }
}
function CreateTheXInputs(){
    let InitialX=Zone0.minX+6/8*(Zone0.minY-Zone0.minX);
    let InitialY=Zone0.minY;
    let SeparationX=0;
    let SeparationY=25;
    let aux=[InitialX,InitialY];
    let CorrectionForTextX=125;
    let CorrectionForTextY=15;

    inpMethane=createInput((x[1]*100).toString());          //1 - Methane
    inpMethane.size(31,13);
    inpMethane.position(aux[0],aux[1]);
    createP('Methane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:Black'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpNitrogen=createInput((x[2]*100).toString());         //2 - Nitrogen
    inpNitrogen.size(31,13);
    inpNitrogen.position(aux[0],aux[1]);
    createP('Nitrogen: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;   

    inpCarbonDioxide=createInput((x[3]*100).toString());    //3 - CarbonDioxide
    inpCarbonDioxide.size(31,13);
    inpCarbonDioxide.position(aux[0],aux[1]);
    createP('Carbon Dioxide: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpEthane=createInput((x[4]*100).toString());           //4 - Ethane
    inpEthane.size(31,13);
    inpEthane.position(aux[0],aux[1]);
    createP('Ethane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpPropane=createInput((x[5]*100).toString());          //5 - Propane
    inpPropane.size(31,13);
    inpPropane.position(aux[0],aux[1]);
    createP('Propane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpIsoButane=createInput((x[6]*100).toString());        //6 - IsoButane
    inpIsoButane.size(31,13);
    inpIsoButane.position(aux[0],aux[1]);
    createP('IsoButane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpnButane=createInput((x[7]*100).toString());          //7 - nButane
    inpnButane.size(31,13);
    inpnButane.position(aux[0],aux[1]);
    createP('nButane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;

    inpIsopentane=createInput((x[8]*100).toString());       //8 - Isopentane
    inpIsopentane.size(31,13);
    inpIsopentane.position(aux[0],aux[1]);
    createP('Isopentane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnPentane=createInput((x[9]*100).toString());         //9 - nPentane
    inpnPentane.size(31,13);
    inpnPentane.position(aux[0],aux[1]);
    createP('nPentane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnHexane=createInput((x[10]*100).toString());         //10 - nHexane
    inpnHexane.size(31,13);
    inpnHexane.position(aux[0],aux[1]);
    createP('nHexane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnHeptane=createInput((x[11]*100).toString());        //11 - nHeptane
    inpnHeptane.size(31,13);
    inpnHeptane.position(aux[0],aux[1]);
    createP('nHeptane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnOctane=createInput((x[12]*100).toString());         //12 - nOctane
    inpnOctane.size(31,13);
    inpnOctane.position(aux[0],aux[1]);
    createP('nOctane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnNonane=createInput((x[13]*100).toString());         //13 - nNonane
    inpnNonane.size(31,13);
    inpnNonane.position(aux[0],aux[1]);
    createP('nNonane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpnDecane=createInput((x[14]*100).toString());         //14 - nDecane
    inpnDecane.size(31,13);
    inpnDecane.position(aux[0],aux[1]);
    createP('nDecane: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpHydrogen=createInput((x[15]*100).toString());        //15 - Hydrogen
    inpHydrogen.size(31,13);
    inpHydrogen.position(aux[0],aux[1]);
    createP('Hydrogen: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpOxygen=createInput((x[16]*100).toString());          //16 - Oxygen
    inpOxygen.size(31,13);
    inpOxygen.position(aux[0],aux[1]);
    createP('Oxygen: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpCarbonMonoxide=createInput((x[17]*100).toString());  //17 - CarbonMonoxide
    inpCarbonMonoxide.size(31,13);
    inpCarbonMonoxide.position(aux[0],aux[1]);
    createP('Carbon Monoxide: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpWater=createInput((x[18]*100).toString());           //18 - Water
    inpWater.size(31,13);
    inpWater.position(aux[0],aux[1]);
    createP('Water: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpHydrogenSulfide=createInput((x[19]*100).toString()); //19 - HydrogenSulfide
    inpHydrogenSulfide.size(31,13);
    inpHydrogenSulfide.position(aux[0],aux[1]);
    createP('Hydrogen Sulfide: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpHelium=createInput((x[20]*100).toString());          //20 - Helium
    inpHelium.size(31,13);
    inpHelium.position(aux[0],aux[1]);
    createP('Helium: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
    
    inpArgon=createInput((x[21]*100).toString());           //21 - Argon
    inpArgon.size(31,13);
    inpArgon.position(aux[0],aux[1]);
    createP('Argon: ').position(aux[0]-CorrectionForTextX,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    createP(' %').position(aux[0]+40,aux[1]-CorrectionForTextY).style('color:'+TextColor);
    aux[0]=aux[0]+SeparationX;
    aux[1]=aux[1]+SeparationY;
}
function RunFuelGas(){
    FuelGas.CalorificValue=x[1]*9.97+x[2]*0+x[3]*0+x[4]*17.87+x[5]*25.89+x[6]*34.05+x[7]*34.3+x[8]*43.51+x[9]*45.51+x[10]*52.67+x[11]*54.67+x[12]*54.67+x[13]*54.67+x[14]*54.67+x[15]*2.99+x[16]*0+x[17]*3.51+x[18]*0+x[19]*0+x[20]*0+x[21]*0;
}