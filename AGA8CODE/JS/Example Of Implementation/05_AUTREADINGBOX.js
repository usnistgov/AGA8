function InputIsActivated(){
    if(InputFromXLS.InputTextArea.value() != ''){
        generateTable(InputFromXLS.InputTextArea.value());
    }
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
    InputFromXLS.InputTextArea.value('');
    NormalizeX();
    FromXToDOMs();
    CalculateGERG2008();
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
