document.write('<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5/jquery.min.js"><\/script>');

const myfunc=()=>{
    allButtons=document.getElementsByName('acceptReject');
    for (let i=0;i<allButtons.length;i++){
        allButtons[i].addEventListener('click',(event)=>{
            data_send=JSON.stringify(allButtons[i].id)
            $.ajax({url:"/decideswap", type:"POST", contentType: "application/json", data: data_send,
            success: function() {
                window.location.href = "/pendingswap";
            }});
        })
    }
}
myfunc();