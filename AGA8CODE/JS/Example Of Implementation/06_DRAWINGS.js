//Charts
let PXToDraw=Array(100);
let PYToDraw=Array(10);
let TXToDraw=Array(100);
let TYToDraw=Array(10);
let DZToDraw=zeros([9, 99]);
let VZToDraw=zeros([9, 99]);
let HZToDraw=zeros([9, 99]);
let HZ2ToDraw=zeros([9, 99]);
let SZ2ToDraw=zeros([9, 99]);
let UpLeftCorner=Array(225,78);
let DownRightCorner=Array(662,789);
let maximumValueOfS;
let minimumValueOfS;
let maximumValueOfH;
let minimumValueOfH;
function SetupXsOfDrawing(){
    let PMinimum = 50;
    let PMaximum = 1000;
    let TMinimum = 225;
    let TMaximum = 450;
    for(let i=0; i<100; i++){
        PXToDraw[i]= map(i,0,99,PMinimum,PMaximum);
    }
    for(let i=0; i<10; i++){
        PYToDraw[i]= map(i,0,9,PMinimum,PMaximum);
    }
    for(let i=0; i<100; i++){
        TXToDraw[i]= map(i,0,99,TMinimum,TMaximum);
    }
    for(let i=0; i<10; i++){
        TYToDraw[i]= map(i,0,9,TMinimum,TMaximum);
    }
}
function CalculateDrawedData(){
    maximumValueOfS=SZ2ToDraw[0][99];
    minimumValueOfS=SZ2ToDraw[9][0];
    maximumValueOfH=SZ2ToDraw[0][99];
    minimumValueOfH=SZ2ToDraw[9][0];
    for(let i=0; i<=9; i++){
        for(let j=0; j<=99; j++){
            GERG.Pressure = PXToDraw[j];
            GERG.Temperature = TYToDraw[i];
            GERG.CalculateDensity(iFlag,GERG.Temperature,GERG.Pressure,x);
            if (GERG.ierr != 1){
                DZToDraw[i][j] = GERG.Density;
                VZToDraw[i][j] = 1 / (GERG.Density + 0.00002);
                HZToDraw[i][j] = GERG.H;
            }
            GERG.Pressure = PYToDraw[i];
            GERG.Temperature = TXToDraw[j];
            GERG.CalculateDensity(iFlag,GERG.Temperature,GERG.Pressure,x);
            if (GERG.ierr != 1){
                HZ2ToDraw[i][j] = GERG.H;
                SZ2ToDraw[i][j] = GERG.S;
            }
            if(SZ2ToDraw[i][j]< minimumValueOfS){minimumValueOfS=SZ2ToDraw[i][j]}
            if(SZ2ToDraw[i][j]> maximumValueOfS){maximumValueOfS=SZ2ToDraw[i][j]}
            if(HZ2ToDraw[i][j]< minimumValueOfH){minimumValueOfH=HZ2ToDraw[i][j]}
            if(HZ2ToDraw[i][j]> maximumValueOfH){maximumValueOfH=HZ2ToDraw[i][j]}
        }
    }
    //Debugger part
    for(let i=0; i<=9; i++){
        for(let j=1; j<=99; j++){
            if(DZToDraw[i][j-1] > DZToDraw[i][j]){
                DZToDraw[i][j] = DZToDraw[i][j-1];
                VZToDraw[i][j] = 1 / (DZToDraw[i][j-1] + 0.00002);
                HZToDraw[i][j] = HZToDraw[i][j-1];
            }
        }
        for(let j=0; j<=98; j++){
            if(HZToDraw[i][j+1] > HZToDraw[i][j]){HZToDraw[i][j+1] = HZToDraw[i][j]}
        }
        for(let j=99; j>=1; j--){
            if(HZ2ToDraw[i][j-1] > HZ2ToDraw[i][j]){HZ2ToDraw[i][j-1] = HZ2ToDraw[i][j]}
            if(SZ2ToDraw[i][j-1] > SZ2ToDraw[i][j]){SZ2ToDraw[i][j-1] = SZ2ToDraw[i][j]}
        }
    }
}
function DrawPD(){
    for(let j=0; j<10; j++){
        for(let i=0; i<100; i++){
            let xi = map(PXToDraw[i],PXToDraw[0],PXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yi = map(DZToDraw[j][i],DZToDraw[0][99],DZToDraw[9][0],DownRightCorner[1],UpLeftCorner[1], true);
            let xj = map(PXToDraw[i+1],PXToDraw[0],PXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yj = map(DZToDraw[j][i+1],DZToDraw[0][99],DZToDraw[9][0],DownRightCorner[1],UpLeftCorner[1], true);
            line(yi,xi,yj,xj);
        }
    }
}
function DrawPV(){
    for(let j=0; j<10; j++){
        for(let i=0; i<99; i++){
            let xi = map(PXToDraw[i],PXToDraw[0],PXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yi = map(VZToDraw[j][i],VZToDraw[9][0],VZToDraw[0][99],DownRightCorner[1],UpLeftCorner[1], true);
            let xj = map(PXToDraw[i+1],PXToDraw[0],PXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yj = map(VZToDraw[j][i+1],VZToDraw[9][0],VZToDraw[0][99],DownRightCorner[1],UpLeftCorner[1], true);
            line(yi,xi,yj,xj);
        }
    }
}
function DrawPH(){
    for(let j=0; j<10; j++){
        for(let i=0; i<99; i++){
            let xi = map(PXToDraw[i],PXToDraw[0],PXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yi = map(HZToDraw[j][i],HZToDraw[0][99],HZToDraw[9][0],DownRightCorner[1],UpLeftCorner[1], true);
            let xj = map(PXToDraw[i+1],PXToDraw[0],PXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yj = map(HZToDraw[j][i+1],HZToDraw[0][99],HZToDraw[9][0],DownRightCorner[1],UpLeftCorner[1], true);
            line(yi,xi,yj,xj);
        }
    }
}
function DrawTH(){
    for(let j=0; j<10; j++){
        for(let i=0; i<99; i++){
            let xi = map(TXToDraw[i],TXToDraw[0],TXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yi = map(HZ2ToDraw[j][i],maximumValueOfH,minimumValueOfH,DownRightCorner[1],UpLeftCorner[1], true);
            let xj = map(TXToDraw[i+1],TXToDraw[0],TXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yj = map(HZ2ToDraw[j][i+1],maximumValueOfH,minimumValueOfH,DownRightCorner[1],UpLeftCorner[1], true);
            line(yi,xi,yj,xj);
        }
    }
}
function DrawTS(){
    for(let j=0; j<10; j++){
        for(let i=0; i<99; i++){
            let xi = map(TXToDraw[i],TXToDraw[0],TXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yi = map(SZ2ToDraw[j][i],maximumValueOfS,minimumValueOfS,DownRightCorner[1],UpLeftCorner[1], true);
            let xj = map(TXToDraw[i+1],TXToDraw[0],TXToDraw[99],DownRightCorner[0],UpLeftCorner[0], true);
            let yj = map(SZ2ToDraw[j][i+1],maximumValueOfS,minimumValueOfS,DownRightCorner[1],UpLeftCorner[1], true);
            line(yi,xi,yj,xj);
        }
    }
}
function FindTheClickedPointPD(){
    if(mouseX < DownRightCorner[1] && mouseY < DownRightCorner[0] && mouseX > UpLeftCorner[1] && mouseY > UpLeftCorner[0]){
        GERG.Pressure = map(mouseY,DownRightCorner[0],UpLeftCorner[0],PXToDraw[0],PXToDraw[99]);
        let DesiredDensity=map(mouseX,DownRightCorner[1],UpLeftCorner[1],DZToDraw[0][99],DZToDraw[9][0]);
        //Start Binary Search
        let TemperatureUp=TYToDraw[9];
        let TemperatureDown=TYToDraw[0];
        let TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
        let DensityMiddle=0;
        for(let i=0; i<=25; i++){
            GERG.CalculateDensity(iFlag,TemperatureMiddle,GERG.Pressure,x);
            DensityMiddle = GERG.Density;
            if (DesiredDensity < DensityMiddle){
                TemperatureDown=TemperatureMiddle;
                TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
            }else{
                TemperatureUp=TemperatureMiddle;
                TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
            }
        }
        if (abs(DesiredDensity - DensityMiddle) < 0.01){
            GERG.Temperature = TemperatureMiddle;
            DrawResultOfMouseData();
        }
    }
}
function FindTheClickedPointPV(){
    if(mouseX < DownRightCorner[1] && mouseY < DownRightCorner[0] && mouseX > UpLeftCorner[1] && mouseY > UpLeftCorner[0]){
        GERG.Pressure = map(mouseY,DownRightCorner[0],UpLeftCorner[0],PXToDraw[0],PXToDraw[99]);
        let DesiredDensity=1 / map(mouseX,DownRightCorner[1],UpLeftCorner[1],VZToDraw[9][0],VZToDraw[0][99]);
        //Start Binary Search
        let TemperatureUp=TYToDraw[9];
        let TemperatureDown=TYToDraw[0];
        let TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
        let DensityMiddle=0;
        for(let i=0; i<=25; i++){
            GERG.CalculateDensity(iFlag,TemperatureMiddle,GERG.Pressure,x);
            DensityMiddle = GERG.Density;
            if (DesiredDensity < DensityMiddle){
                TemperatureDown=TemperatureMiddle;
                TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
            }else{
                TemperatureUp=TemperatureMiddle;
                TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
            }
        }
        if (abs(DesiredDensity - DensityMiddle) < 0.01){
            GERG.Temperature = TemperatureMiddle;
            DrawResultOfMouseData();
        }
    }
}
function FindTheClickedPointPH(){
    if(mouseX < DownRightCorner[1] && mouseY < DownRightCorner[0] && mouseX > UpLeftCorner[1] && mouseY > UpLeftCorner[0]){
        GERG.Pressure = map(mouseY,DownRightCorner[0],UpLeftCorner[0],PXToDraw[0],PXToDraw[99]);
        let DesiredEntalphy=map(mouseX,DownRightCorner[1],UpLeftCorner[1],HZToDraw[9][0],HZToDraw[0][0]);
        //Start Binary Search
        let TemperatureUp=TYToDraw[9];
        let TemperatureDown=TYToDraw[0];
        let TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
        let EntalphyMiddle=0;
        for(let i=0; i<=25; i++){
            GERG.CalculateDensity(iFlag,TemperatureMiddle,GERG.Pressure,x);
            EntalphyMiddle = GERG.H;
            if (DesiredEntalphy < EntalphyMiddle){
                TemperatureUp=TemperatureMiddle;
                TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
            }else{
                TemperatureDown=TemperatureMiddle;
                TemperatureMiddle=(TemperatureUp+TemperatureDown)/2;
            }
        }
        if (abs(DesiredEntalphy - EntalphyMiddle) < 100){
            GERG.Temperature = TemperatureMiddle;
            DrawResultOfMouseData();
        }
    }
}
function FindTheClickedPointTH(){
    if(mouseX < DownRightCorner[1] && mouseY < DownRightCorner[0] && mouseX > UpLeftCorner[1] && mouseY > UpLeftCorner[0]){
        GERG.Temperature = map(mouseY,DownRightCorner[0],UpLeftCorner[0],TXToDraw[0],TXToDraw[99]);
        let DesiredEntalphy=map(mouseX,DownRightCorner[1],UpLeftCorner[1],maximumValueOfH,minimumValueOfH);
        //Start Binary Search
        let PressureUp=PYToDraw[9];
        let PressureDown=PYToDraw[0];
        let PressureMiddle=(PressureUp+PressureDown)/2;
        let EntalphyMiddle=0;
        for(let i=0; i<=25; i++){
            GERG.CalculateDensity(iFlag,GERG.Temperature,PressureMiddle,x);
            EntalphyMiddle = GERG.H;
            if (DesiredEntalphy < EntalphyMiddle){
                PressureDown=PressureMiddle;
                PressureMiddle=(PressureUp+PressureDown)/2;
            }else{
                PressureUp=PressureMiddle;
                PressureMiddle=(PressureUp+PressureDown)/2;
            }
        }
        if (abs(DesiredEntalphy - EntalphyMiddle) < 100){
            GERG.Pressure = PressureMiddle;
            DrawResultOfMouseData();
        }
    }
}
function FindTheClickedPointTS(){
    if(mouseX < DownRightCorner[1] && mouseY < DownRightCorner[0] && mouseX > UpLeftCorner[1] && mouseY > UpLeftCorner[0]){
        GERG.Temperature = map(mouseY,DownRightCorner[0],UpLeftCorner[0],TXToDraw[0],TXToDraw[99]);
        let DesiredEntropy=map(mouseX,DownRightCorner[1],UpLeftCorner[1],maximumValueOfS,minimumValueOfS);
        //Start Binary Search
        let PressureUp=PYToDraw[9];
        let PressureDown=PYToDraw[0];
        let PressureMiddle=(PressureUp+PressureDown)/2;
        let EntropyMiddle=0;
        for(let i=0; i<=25; i++){
            GERG.CalculateDensity(iFlag,GERG.Temperature,PressureMiddle,x);
            EntropyMiddle = GERG.S;
            if (DesiredEntropy < EntropyMiddle){
                PressureDown=PressureMiddle;
                PressureMiddle=(PressureUp+PressureDown)/2;
            }else{
                PressureUp=PressureMiddle;
                PressureMiddle=(PressureUp+PressureDown)/2;
            }
        }
        if (abs(DesiredEntropy - EntropyMiddle) < 100){
            GERG.Pressure = PressureMiddle;
            DrawResultOfMouseData();
        }
    }
}
function DrawResultOfMouseData(){
    let PositionOfGERGColumn=820;
    let aux=250;
    push();
    fill(CanvasLeterColor);
    textSize(15);
    textFont('Georgia');
    textStyle(NORMAL);
    fill(CanvasLeterColor);
    text('Temperature: '+ GERG.Temperature.toFixed(1) + ' K',PositionOfGERGColumn,aux);
    aux=aux+25;
    text('Pressure: '+ GERG.Pressure.toFixed(1) + ' Kpa',PositionOfGERGColumn,aux);
    aux=aux+25;
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
