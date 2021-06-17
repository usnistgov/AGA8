let RGERG;
let NcGERG = 21;
let MaxFlds = 21;
let MaxMdl = 10;
let MaxTrmM = 12;
let MaxTrmP= 24;
let Epsilon = 0.000000000000001;  //1d-15
let coik=zeros([MaxFlds, MaxTrmP]);
let doik=zeros([MaxFlds, MaxTrmP]);
let dijk=zeros([MaxMdl, MaxTrmM]);
let mNumb=zeros([MaxFlds, MaxFlds]);
let kpol=Array(MaxFlds+1).fill(0);
let kexp=Array(MaxFlds+1).fill(0);
let kpolij=Array(MaxMdl+1).fill(0);
let kexpij=Array(MaxMdl+1).fill(0);
let Drold=0;
let Trold=0;
let Told;
let Trold2;
let xold=Array(MaxFlds+1).fill(0);
let Dc=Array(MaxFlds+1).fill(0);
let Tc=Array(MaxFlds+1).fill(0);
let MMiGERG=Array(MaxFlds+1).fill(0);
let Vc3=Array(MaxFlds+1).fill(0);
let Tc2=Array(MaxFlds+1).fill(0);
let cijk=zeros([MaxMdl, MaxTrmM]);
let noik=zeros([MaxFlds, MaxTrmP]);
let toik=zeros([MaxFlds, MaxTrmP]);
let eijk=zeros([MaxMdl, MaxTrmM]);
let gijk=zeros([MaxMdl, MaxTrmM]);
let nijk=zeros([MaxMdl, MaxTrmM]);
let tijk=zeros([MaxMdl, MaxTrmM]);
let btij=zeros([MaxFlds, MaxFlds]);
let bvij=zeros([MaxFlds, MaxFlds]);
let gtij=zeros([MaxFlds, MaxFlds]);
let gvij=zeros([MaxFlds, MaxFlds]);
let fij=zeros([MaxFlds, MaxFlds]);
let th0i=zeros([MaxFlds, 7]);
let n0i=zeros([MaxFlds, 7]);
let taup=zeros([MaxFlds, MaxTrmP]);
let taupijk=zeros([MaxFlds, MaxTrmM]);
let dPdDsave; //Calculated in the PressureGERG subroutine, but not included as an argument since it is only used internally in the density algorithm.
let RGross=0;
let NcGross = 21;
let RDetail;
const NcDetail = 21;
let NTerms = 58;
let fn=Array(NTerms+1).fill(0);
let gn=Array(NTerms+1).fill(0);
let qn=Array(NTerms+1).fill(0);
let an=Array(NTerms+1).fill(0);
let bn=Array(NTerms+1).fill(0);
let kn=Array(NTerms+1).fill(0);
let un=Array(NTerms+1).fill(0);
let Bsnij2=zeros([MaxFlds, MaxFlds,18]);
let Bs=Array(18+1).fill(0);
let Csn=Array(NTerms+1).fill(0);
let Fi=Array(MaxFlds+1).fill(0);
let Gi=Array(MaxFlds+1).fill(0);
let Qi=Array(MaxFlds+1).fill(0);
let Ki25=Array(MaxFlds+1).fill(0);
let Ei25=Array(MaxFlds+1).fill(0);
let Kij5=zeros([MaxFlds, MaxFlds]);
let Uij5=zeros([MaxFlds, MaxFlds]);
let Gij5=zeros([MaxFlds, MaxFlds]);
let Tun=Array(NTerms+1).fill(0);
let MMiDetail=Array(MaxFlds+1).fill(0);
let K3=0;
let mN2=0;
let mCO2=0;
let xHN=Array(MaxFlds+1).fill(0);
let MMiGross=Array(MaxFlds+1).fill(0);
let b0=zeros([3, 3]);
let b1=zeros([3, 3]);
let b2=zeros([3, 3]);
let bCHx=zeros([2, 2]);
let cCHx=zeros([2, 2]);
let c0=zeros([3, 3, 3]);
let c1=zeros([3, 3, 3]);
let c2=zeros([3, 3, 3]);
let x=Array(22).fill(0);
let InputFromXLS=null;
function Tanh(xx){
    return (Math.exp(xx) - Math.exp(-xx)) / (Math.exp(xx) + Math.exp(-xx));
} 
function Sinh(xx){
    return (Math.exp(xx) - Math.exp(-xx)) / 2;
}
function Cosh(xx){
    return (Math.exp(xx) + Math.exp(-xx)) / 2;
}
function zeros(dimensions) {
    var array = [];
    for (var i = 0; i <= dimensions[0]; ++i) {
        array.push(dimensions.length == 1 ? 0 : zeros(dimensions.slice(1)));
    }
    return array;
}