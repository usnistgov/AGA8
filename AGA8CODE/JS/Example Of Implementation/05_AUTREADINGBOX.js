function CreateTheMagicBox(){
    InputFromXLS=select('#PasteXLS');
    InputFromXLS.input(InputIsActivated);
    InputFromXLS.position(450,550);
}
function InputIsActivated(){
    if(InputFromXLS.elt.value != ''){
        generateTable(InputFromXLS.elt.value);
    };
}
function generateTable(data) {
    x=Array(22).fill(0);
    data = data.split("\n");
    let NumberOfRows = data.length;
    DeleteEmptySpaces();
    for(let i=0; i < NumberOfRows; i++){
        data[i] = data[i].split('\t');
    }
    let NumberOfColumns = data[0].length;
    for(let i=0; i < NumberOfRows; i++){
        for(let j=0; j < NumberOfColumns; j++){
            if(NumberOfColumns != data[i].length){console.log('Error reading the row/column '+ j + 1)}
            data[i][j] = data[i][j].replace(' ', ''); //Delete black spaces if presents.
        }
    }
    if (NumberOfColumns != 2 && NumberOfRows !=2){console.log('More than 2 rows/columns detected')} //I need the labels and the rows. if there are more data something must go wrong.
    //Check if i need to transpose
    if (NumberOfColumns != 2){
        TransposeTheDataArray();
    }
    for(let i=0; i < NumberOfRows; i++){
        data[i][0] = data[i][0].toUpperCase();
        //    1 - Methane
        if(data[i][0] == 'C1'){x[1]=x[1]+parseFloat(data[i][1])}
        if(data[i][0] == 'CH4'){x[1]=x[1]+parseFloat(data[i][1])}
        if(data[i][0] == 'METHANE'){x[1]=x[1]+parseFloat(data[i][1])} 
        //    2 - Nitrogen
        if(data[i][0] == "N2"){x[2]=x[2]+parseFloat(data[i][1])}
        if(data[i][0] == "NITROGEN"){x[2]=x[2]+parseFloat(data[i][1])}
        if(data[i][0] == "N"){x[2]=x[2]+parseFloat(data[i][1])}
        //    3 - Carbon dioxide
        if(data[i][0] == 'CO2'){x[3]=x[3]+parseFloat(data[i][1])}
        if(data[i][0] == 'CARBON DIOXIDE'){x[3]=x[3]+parseFloat(data[i][1])}
        if(data[i][0] == 'CARBONIC ACID'){x[3]=x[3]+parseFloat(data[i][1])}
        //    4 - Ethane
        if(data[i][0] == 'C2'){x[4]=x[4]+parseFloat(data[i][1])}
        if(data[i][0] == 'C2H6'){x[4]=x[4]+parseFloat(data[i][1])}
        if(data[i][0] == 'ETHANE'){x[4]=x[4]+parseFloat(data[i][1])}
        //    5 - Propane
        if(data[i][0] == 'C3'){x[5]=x[5]+parseFloat(data[i][1])}
        if(data[i][0] == 'C3H8'){x[5]=x[5]+parseFloat(data[i][1])}
        if(data[i][0] == 'PROPANE'){x[5]=x[5]+parseFloat(data[i][1])}
        //    6 - Isobutane
        if(data[i][0] == 'IC4'){x[6]=x[6]+parseFloat(data[i][1])}
        if(data[i][0] == 'IC4H10'){x[6]=x[6]+parseFloat(data[i][1])}
        if(data[i][0] == 'ISOBUTANE'){x[6]=x[6]+parseFloat(data[i][1])}
        //    7 - n-Butane
        if(data[i][0] == 'NC4'){x[7]=x[7]+parseFloat(data[i][1])}
        if(data[i][0] == 'C4'){x[7]=x[7]+parseFloat(data[i][1])}
        if(data[i][0] == 'NC4H10'){x[7]=x[7]+parseFloat(data[i][1])}
        if(data[i][0] == 'NORMALBUTANE'){x[7]=x[7]+parseFloat(data[i][1])}
        if(data[i][0] == 'NORMAL BUTANE'){x[7]=x[7]+parseFloat(data[i][1])}
        if(data[i][0] == 'BUTANE'){x[7]=x[7]+parseFloat(data[i][1])}
        //    8 - Isopentane
        if(data[i][0] == 'IC5'){x[8]=x[8]+parseFloat(data[i][1])}
        if(data[i][0] == 'IC5H12'){x[8]=x[8]+parseFloat(data[i][1])}
        if(data[i][0] == 'ISOPENTANE'){x[8]=x[8]+parseFloat(data[i][1])}
        //    9 - n-Pentane
        if(data[i][0] == 'NC5'){x[9]=x[9]+parseFloat(data[i][1])}
        if(data[i][0] == 'C5'){x[9]=x[9]+parseFloat(data[i][1])}
        if(data[i][0] == 'NC5H12'){x[9]=x[9]+parseFloat(data[i][1])}
        if(data[i][0] == 'NORMALPENTANE'){x[9]=x[9]+parseFloat(data[i][1])}
        if(data[i][0] == 'NORMAL PENTANE'){x[9]=x[9]+parseFloat(data[i][1])}
        if(data[i][0] == 'PENTANE'){x[9]=x[9]+parseFloat(data[i][1])}
        //   10 - n-Hexane
        if(data[i][0] == 'NC6'){x[10]=x[10]+parseFloat(data[i][1])}
        if(data[i][0] == 'C6'){x[10]=x[10]+parseFloat(data[i][1])}
        if(data[i][0] == 'C6H14'){x[10]=x[10]+parseFloat(data[i][1])}
        if(data[i][0] == 'HEXANE'){x[10]=x[10]+parseFloat(data[i][1])}
        //   11 - n-Heptane
        if(data[i][0] == 'NC7'){x[11]=x[11]+parseFloat(data[i][1])}
        if(data[i][0] == 'C7'){x[11]=x[11]+parseFloat(data[i][1])}
        if(data[i][0] == 'C7H16'){x[11]=x[11]+parseFloat(data[i][1])}
        if(data[i][0] == 'HEPTANE'){x[11]=x[11]+parseFloat(data[i][1])}
        //   12 - n-Octane
        if(data[i][0] == 'NC8'){x[12]=x[12]+parseFloat(data[i][1])}
        if(data[i][0] == 'C8'){x[12]=x[12]+parseFloat(data[i][1])}
        if(data[i][0] == 'C8H18'){x[12]=x[12]+parseFloat(data[i][1])}
        if(data[i][0] == 'C8H18+'){x[12]=x[12]+parseFloat(data[i][1])}
        if(data[i][0] == 'OCTANE'){x[12]=x[12]+parseFloat(data[i][1])}
        //   13 - n-Nonane
        if(data[i][0] == 'NC9'){x[13]=x[13]+parseFloat(data[i][1])}
        if(data[i][0] == 'C9'){x[13]=x[13]+parseFloat(data[i][1])}
        if(data[i][0] == 'C9H20'){x[13]=x[13]+parseFloat(data[i][1])}
        if(data[i][0] == 'C9H20+'){x[13]=x[13]+parseFloat(data[i][1])}
        if(data[i][0] == 'NONANE'){x[13]=x[13]+parseFloat(data[i][1])}
        //   14 - n-Decane
        if(data[i][0] == 'NC10'){x[14]=x[14]+parseFloat(data[i][1])}
        if(data[i][0] == 'C10'){x[14]=x[14]+parseFloat(data[i][1])}
        if(data[i][0] == 'C10H22'){x[14]=x[14]+parseFloat(data[i][1])}
        if(data[i][0] == 'C10H22+'){x[14]=x[14]+parseFloat(data[i][1])}
        if(data[i][0] == 'DECANO'){x[14]=x[14]+parseFloat(data[i][1])}        
        //   15 - Hydrogen
        if(data[i][0] == 'H2'){x[15]=x[15]+parseFloat(data[i][1])}
        if(data[i][0] == 'H'){x[15]=x[15]+parseFloat(data[i][1])}
        if(data[i][0] == 'HYDROGEN'){x[15]=x[15]+parseFloat(data[i][1])}
        //   16 - Oxygen
        if(data[i][0] == 'O2'){x[16]=x[16]+parseFloat(data[i][1])}
        if(data[i][0] == 'O'){x[16]=x[16]+parseFloat(data[i][1])}
        if(data[i][0] == 'OXYGEN'){x[16]=x[16]+parseFloat(data[i][1])}
        //   17 - Carbon monoxide
        if(data[i][0] == 'CO'){x[17]=x[17]+parseFloat(data[i][1])}
        if(data[i][0] == 'CARBON MONOXIDE'){x[17]=x[17]+parseFloat(data[i][1])}
        //   18 - Water
        if(data[i][0] == 'H2O'){x[18]=x[18]+parseFloat(data[i][1])}
        if(data[i][0] == 'OH2'){x[18]=x[18]+parseFloat(data[i][1])}
        if(data[i][0] == 'WATER'){x[18]=x[18]+parseFloat(data[i][1])}
        //   19 - Hydrogen sulfide
        if(data[i][0] == 'H2S'){x[19]=x[19]+parseFloat(data[i][1])}
        if(data[i][0] == 'SH2'){x[19]=x[19]+parseFloat(data[i][1])}
        if(data[i][0] == 'HYDROGEN SULPHIDE'){x[19]=x[19]+parseFloat(data[i][1])}
        //   20 - Helium
        if(data[i][0] == 'HE'){x[20]=x[20]+parseFloat(data[i][1])}
        if(data[i][0] == 'HELIUM'){x[20]=x[20]+parseFloat(data[i][1])}
        //   21 - Argon
        if(data[i][0] == 'AR'){x[21]=x[21]+parseFloat(data[i][1])}
        if(data[i][0] == 'ARGON'){x[21]=x[21]+parseFloat(data[i][1])}
    }
    InputFromXLS.elt.value = '';
    //Normalization
    let SumOfComponents=0;
    for(let i=1; i <= 21; i++){
        SumOfComponents=SumOfComponents+x[i];
    }
    for(let i=1; i <= 21; i++){
        x[i]=x[i]/SumOfComponents;
    }
    FromXToDOMs();
    function TransposeTheDataArray(){
        let Auxiliary=Array(NumberOfColumns).fill(0);
        for(let i=0; i < NumberOfColumns; i++){
            Auxiliary[i]=Array(NumberOfRows).fill(0);
            for(let j=0; j < NumberOfRows; j++){
                Auxiliary[i][j]=data[j][i];
            }
        }
        data=Auxiliary;
        NumberOfRows=NumberOfColumns;
    }
    function DeleteEmptySpaces(){
        for(let i=0; i < NumberOfRows; i++){
            if(data[i] == ''){data.splice(i,i)}
        }
        NumberOfRows = data.length;    
    }
}
let TextAreaBoxVariables={
    PossibleLabel:Array(64).fill(0),
    ColumnBoxLabels:Array(12).fill(0),
    ColumnBoxValues:Array(12).fill(0),
    RowBoxLabels:Array(8).fill(0),
    RowBoxValues:Array(8).fill(0),
}
function SetupTheTextAreaAnimation(){
    TextAreaBoxVariables.PossibleLabel[0]='C1';
    TextAreaBoxVariables.PossibleLabel[1]='CH4';
    TextAreaBoxVariables.PossibleLabel[2]='Methane'; 
    TextAreaBoxVariables.PossibleLabel[3]='N2';
    TextAreaBoxVariables.PossibleLabel[4]='Nitrogen';
    TextAreaBoxVariables.PossibleLabel[5]='N';
    TextAreaBoxVariables.PossibleLabel[6]='CO2';
    TextAreaBoxVariables.PossibleLabel[7]='C2';
    TextAreaBoxVariables.PossibleLabel[8]='C2H6';
    TextAreaBoxVariables.PossibleLabel[9]='ETHANE';
    TextAreaBoxVariables.PossibleLabel[10]='C3';
    TextAreaBoxVariables.PossibleLabel[11]='C3H8';
    TextAreaBoxVariables.PossibleLabel[12]='Propane';
    TextAreaBoxVariables.PossibleLabel[13]='IC4';
    TextAreaBoxVariables.PossibleLabel[14]='IC4H10';
    TextAreaBoxVariables.PossibleLabel[15]='NC4';
    TextAreaBoxVariables.PossibleLabel[16]='C4';
    TextAreaBoxVariables.PossibleLabel[17]='NC4H10';
    TextAreaBoxVariables.PossibleLabel[18]='BUTANE';
    TextAreaBoxVariables.PossibleLabel[19]='IC5';
    TextAreaBoxVariables.PossibleLabel[20]='IC5H12';
    TextAreaBoxVariables.PossibleLabel[21]='NC5';
    TextAreaBoxVariables.PossibleLabel[22]='C5';
    TextAreaBoxVariables.PossibleLabel[23]='NC5H12';
    TextAreaBoxVariables.PossibleLabel[24]='PENTANE';
    TextAreaBoxVariables.PossibleLabel[25]='NC6';
    TextAreaBoxVariables.PossibleLabel[26]='C6';
    TextAreaBoxVariables.PossibleLabel[27]='C6H14';
    TextAreaBoxVariables.PossibleLabel[28]='HEXANE';
    TextAreaBoxVariables.PossibleLabel[29]='NC7';
    TextAreaBoxVariables.PossibleLabel[30]='C7';
    TextAreaBoxVariables.PossibleLabel[31]='C7H16';
    TextAreaBoxVariables.PossibleLabel[32]='HEPTANE';
    TextAreaBoxVariables.PossibleLabel[33]='NC8';
    TextAreaBoxVariables.PossibleLabel[34]='C8';
    TextAreaBoxVariables.PossibleLabel[35]='C8H18';
    TextAreaBoxVariables.PossibleLabel[36]='C8H18+';
    TextAreaBoxVariables.PossibleLabel[37]='OCTANE';
    TextAreaBoxVariables.PossibleLabel[38]='NC9';
    TextAreaBoxVariables.PossibleLabel[39]='C9';
    TextAreaBoxVariables.PossibleLabel[40]='C9H20';
    TextAreaBoxVariables.PossibleLabel[41]='C9H20+';
    TextAreaBoxVariables.PossibleLabel[42]='NONANE';
    TextAreaBoxVariables.PossibleLabel[43]='NC10';
    TextAreaBoxVariables.PossibleLabel[44]='C10';
    TextAreaBoxVariables.PossibleLabel[45]='C10H22';
    TextAreaBoxVariables.PossibleLabel[46]='C10H22+';
    TextAreaBoxVariables.PossibleLabel[47]='DECANO';        
    TextAreaBoxVariables.PossibleLabel[48]='H2';
    TextAreaBoxVariables.PossibleLabel[49]='H';
    TextAreaBoxVariables.PossibleLabel[50]='Hydrogen';
    TextAreaBoxVariables.PossibleLabel[51]='O2';
    TextAreaBoxVariables.PossibleLabel[52]='O';
    TextAreaBoxVariables.PossibleLabel[53]='OXYGEN';
    TextAreaBoxVariables.PossibleLabel[54]='CO';
    TextAreaBoxVariables.PossibleLabel[55]='H2O';
    TextAreaBoxVariables.PossibleLabel[56]='OH2';
    TextAreaBoxVariables.PossibleLabel[57]='WATER';
    TextAreaBoxVariables.PossibleLabel[58]='H2S';
    TextAreaBoxVariables.PossibleLabel[59]='SH2';
    TextAreaBoxVariables.PossibleLabel[60]='HE';
    TextAreaBoxVariables.PossibleLabel[61]='HELIUM';
    TextAreaBoxVariables.PossibleLabel[62]='AR';
    TextAreaBoxVariables.PossibleLabel[63]='ARGON';
    RandomizeTheTextAreaAnimation();
    function RandomizeTheTextAreaAnimation(){
        let SizeOfPossibleLabel=TextAreaBoxVariables.PossibleLabel.length;
        let num
        for(i=0; i < 12; i++){
            num = int(random(0, SizeOfPossibleLabel));
            TextAreaBoxVariables.ColumnBoxLabels[i]=TextAreaBoxVariables.PossibleLabel[num];
            num = random(30, 90).toFixed(3);
            TextAreaBoxVariables.ColumnBoxValues[i]=num;
        }
        for(i=0; i < 8; i++){
            num = int(random(0, SizeOfPossibleLabel));
            TextAreaBoxVariables.RowBoxLabels[i]=TextAreaBoxVariables.PossibleLabel[num];
            num = random(30, 90).toFixed(3);
            TextAreaBoxVariables.RowBoxValues[i]=num;
        }
    }    
}
function CreateTheAnimation(){
    //Column Box
    let initialPosition=[24,310];
    let BoxIncrements=[100,33];
    let SizeOfPossibleLabel=TextAreaBoxVariables.PossibleLabel.length;
    push();
    textSize(14);
    textStyle(BOLD);
    for(i=0; i < 12; i++){
        text(TextAreaBoxVariables.ColumnBoxLabels[i],initialPosition[0],initialPosition[1]+i*BoxIncrements[1]);
        text(TextAreaBoxVariables.ColumnBoxValues[i],initialPosition[0]+BoxIncrements[0],initialPosition[1]+i*BoxIncrements[1]);
    }
    //Row Box
    initialPosition=[195,310];
    BoxIncrements=[75,35];
    for(i=0; i < 8; i++){
        text(TextAreaBoxVariables.RowBoxLabels[i],initialPosition[0]+i*BoxIncrements[0],initialPosition[1]);
        text(TextAreaBoxVariables.RowBoxValues[i],initialPosition[0]+i*BoxIncrements[0],initialPosition[1]+BoxIncrements[1]);
    }
    pop();
    AnimateTheTextArea();
    function AnimateTheTextArea(){
        let SizeOfPossibleLabel=TextAreaBoxVariables.PossibleLabel.length;
        let num
        for(i=0; i < 12; i++){
            if(random(0,100)< 0.1){
                num = int(random(0, SizeOfPossibleLabel));
                TextAreaBoxVariables.ColumnBoxLabels[i]=TextAreaBoxVariables.PossibleLabel[num];
                num = random(30, 90).toFixed(3);
                TextAreaBoxVariables.ColumnBoxValues[i]=num;
            }
        }
        for(i=0; i < 8; i++){
            if(random(0,100)< 0.1){
            num = int(random(0, SizeOfPossibleLabel));
            TextAreaBoxVariables.RowBoxLabels[i]=TextAreaBoxVariables.PossibleLabel[num];
            num = random(30, 90).toFixed(3);
            TextAreaBoxVariables.RowBoxValues[i]=num;
            }
        }
    }    
}