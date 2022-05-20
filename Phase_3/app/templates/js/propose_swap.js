document.write('<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"><\/script>');

const myfunc=()=>{
    submitButton=document.getElementById('submit');
    submitButton.addEventListener('click',(event)=>{
        //const re = new RegExp('\/proposeswap\/[1-9]+');
        //desired=window.location.href.match(re)[0].slice(13)
        //data_send={'desired':desired,'proposed':[]};
        allRecord=document.getElementsByName('item_to_propose');
        for (let i=0;i<allRecord.length;i++){
            if (allRecord[i].checked) {
                //data_send['proposed'].push(allRecord[i].value);
                data_send.push(allRecord[i].value);
            }
        }
        data_send=JSON.stringify(data_send)
        console.log("data sent:", data_send);
        $.ajax({url:"/propose_swap", type:"POST", contentType: "application/json", data: data_send,
            });
    })
}
myfunc();