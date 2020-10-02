/// adapted from jspsych.org ///

var mTurk = {

  // core.turkInfo gets information relevant to mechanical turk experiments. returns an object
  // containing the workerID, assignmentID, and hitID, and whether or not the HIT is in
  // preview mode, meaning that they haven't accepted the HIT yet.
  turkInfo : function() {

    var turk = {};

    var param = function(url, name) {
      name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
      var regexS = "[\\?&]" + name + "=([^&#]*)";
      var regex = new RegExp(regexS);
      var results = regex.exec(url);
      return (results == null) ? "" : results[1];
    };

    var src = param(window.location.href, "assignmentId") ? window.location.href : document.referrer;

    var keys = ["assignmentId", "hitId", "workerId", "turkSubmitTo"];
    keys.map(

      function(key) {
        turk[key] = unescape(param(src, key));
      });

    turk.previewMode = (turk.assignmentId == "ASSIGNMENT_ID_NOT_AVAILABLE");

    turk.outsideTurk = (!turk.previewMode && turk.hitId === "" && turk.assignmentId == "" && turk.workerId == "")

    turk_info = turk;

    return turk;

  },

  // core.submitToTurk will submit a MechanicalTurk ExternalHIT type
  // *** MUST BE RUN FROM MTURK IFRAME *** //
  
  // data = key:value pairs
  //   e.g., data = {
  //   "question1" : "answer1",
  //   "question2" : "answer2"
  // }

  // final output URL example:
  // url + "/mturk/externalSubmit?" + data
  //"https://www.mturk.com/mturk/externalSubmit?question1=answer1&question2=answer2&assignmentId=23343234kfkdsn1"

   submitToTurk : function(data) {

    var turkInfo = mTurk.turkInfo();
    var assignmentId = turkInfo.assignmentId;
    var turkSubmitTo = turkInfo.turkSubmitTo;

    if (!assignmentId || !turkSubmitTo) return;

    var dataString = [];

    for (var key in data) {
      if (data.hasOwnProperty(key)) {
        dataString.push(key + "=" + encodeURI(data[key]));
      }
    }

    dataString.push("assignmentId=" + assignmentId);

    var url = turkSubmitTo + "/mturk/externalSubmit?" + dataString.join("&");

    window.location.href = url;
  },
    
 append_array: function(array, formID){
    let form = document.getElementById(formID)
    for(i = 0; i < array.length; i++){
        ni = document.createElement("input")
        ni.setAttribute("type","hidden")
        ni.setAttribute("name",i.toString())
        ni.value = array[i].join(", ")   
        form.appendChild(ni)
    }
  },
      
  append_text: function(text, formID, name){
    let form = document.getElementById(formID)
        ni = document.createElement("input")
        ni.setAttribute("type","hidden")
        ni.setAttribute("name",name)
        ni.value = text 
        form.appendChild(ni)
  }


};
