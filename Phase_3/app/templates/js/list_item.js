//all the dynamic elements
const videoPlatform1=document.getElementById('video_platform');
const videoPlatform2=document.querySelector("label[for=video_platform]");
const videoMedia1=document.getElementById('video_media');
const videoMedia2=document.querySelector("label[for=video_media]");
const computerPlatform1=document.getElementById('computer_platform');
const computerPlatform2=document.querySelector("label[for=computer_platform]");
const pieceCount1=document.getElementById('piececount');
const pieceCount2=document.querySelector("label[for=piececount]");
allEle=[videoPlatform1,videoPlatform2,videoMedia1,videoMedia2,computerPlatform1,computerPlatform2,pieceCount1,pieceCount2];


//board game or card game: all disappear
function boardGame(){
    for (let i=0;i<allEle.length;i++){
        allEle[i].style.display='none';
    }
}
//video game: show 1-4
function videoGame(){
    for (let i=0;i<allEle.length;i++){
        if (i<4){
            allEle[i].style.display='block';
        }
        else {
            allEle[i].style.display='none';
        }
    }
}
//computer game: show 5,6
function computerGame(){
    for (let i=0;i<allEle.length;i++){
        if ((i===4)||(i===5)){
            allEle[i].style.display='block';
        }
        else{
            allEle[i].style.display='none';
        }
    }
}
//jigsaw puzzle: show 7, 8
function jigsawPuzzle(){
    for (let i=0;i<allEle.length;i++){
        if ((i===6)||(i===7)){
            allEle[i].style.display='block';
        }
        else{
            allEle[i].style.display='none';
        }
    }
}


//default display for these dynamic elements
boardGame();
const dynamicOption=()=>{
    gametype.addEventListener('change',(event)=>{
        const gametype=document.getElementById('gametype');
        const curValue=gametype.value;
        if ((curValue==='Board Game')||(curValue==='Card Game')){
            boardGame();
        }
        else if (curValue==='Video Game'){
            videoGame();
        }
        else if (curValue=='Computer Game'){
            computerGame();
        }
        else{
            jigsawPuzzle();
        }
    });
};
dynamicOption();
