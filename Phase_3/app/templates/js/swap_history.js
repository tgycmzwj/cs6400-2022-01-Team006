document.write('<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"><\/script>');


const myfunc=()=>{
    submitButton=document.getElementById('submit');
    submitButton.addEventListener('click',(event)=>{
        data_send=[]
        allRecord=document.getElementsByName('rate');
        for (let i=0;i<allRecord.length;i++){
            data_send.push(allRecord[i].value);
        }
        data_send=JSON.stringify(data_send)
        console.log(data_send);
        $.ajax({url:"/rateswap", type:"POST", contentType: "application/json", data: data_send});
    })
}
myfunc();