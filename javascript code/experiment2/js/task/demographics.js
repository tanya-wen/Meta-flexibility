/**
 * Add-on questionairre
 *
 *   
 *
 **/

const demographics = function () {
    let phase = 0,
        stim_time,
        submit_time,
        q_array = []

    let init = function () {
        eventTimer.cancelAllRequests();

        // create content display within the main-display div
        document.querySelector("#main-display").style.display = "flex"
        document.querySelector("#main-display").innerHTML = '<div class="content-display flex flex-column justify-center lh-copy" style="text-align: left"></div>'

        // 
        quest();
    }


    const quest = function () {
        stim_time = window.performance.now();

        document.querySelector("#main-display").style.display = "flex"
        document.querySelector("#main-display").style.visibility = "hidden"

        document.querySelector("#main-display").innerHTML =
            `<div class="content-display flex items-center flex-column" >
             <div style="width:80%; margin: 0"> 
                <p>Please take a few minutes to respond to the demographic and medical history questions below by filling in the appropriate response.</p>
                <p style="color:red"><em>You will need to complete these questions to submit the form, however, you may choose "do not wish to reply" or type in "do not wish to reply".</em></p>
             </div>
             <div style="width:80%;">
                <p class="question-header">Gender:</p>
                <input type="radio" name="gender" id="gender" value="Male" required> Male <br>
                <input type="radio" name="gender" id="gender" value="Female" required> Female <br>
                <input type="radio" name="gender" id="gender" value="Do not wish to reply" required> Do not wish to reply <br>

                <p><span class="question-header">Age:</span>
                    <input name="age" id="age" type="text" required> </p>

                <p class="question-header">Race:</p>
                    <input type="radio" name="race" id="race" value="American Indian/Alaska Native" required> American Indian/Alaska Native<br>
                    <input type="radio" name="race" id="race" value="Asian" required> Asian <br>
                    <input type="radio" name="race" id="race" value="Native Hawaiian/Other Pacific Islander" required> Native Hawaiian/Other Pacific Islander <br>
                    <input type="radio" name="race" id="race" value="Black/African American" required> Black/African American <br>
                    <input type="radio" name="race" id="race" value="White/Caucasian" required>White/Caucasian<br>
                    <input type="radio" name="race" id="race" value="Multiracial" required> Multiracial <br>
                    <input type="radio" name="race" id="race" value="Other" required> Other <br>
                    <input type="radio" name="race" id="race" value="Do not wish to reply" required> Do not wish to reply <br>

                <p class="question-header">Ethnicity (e.g., Hispanic, Latino, Chinese, Japanese, Arab, Multiple Ethnicities, "Do not wish to reply", etc.):
                    <input name="ethnicity" id="ethnicity" type="text" required> </p>

                <p class="question-header">Are you colorblind?</p>
                    <input type="radio" name="color" id="color" value="yes" required>YES<br>
                    <input type="radio" name="color" id="color" value="no" required>NO<br>
                    <input type="radio" name="color" id="color" value="Do not wish to reply" required> Do not wish to reply <br>

                <p class="question-header">Do you have corrected or corrected-to-normal vision?</p>
                    <input type="radio" name="vision" id="vision" value="yes" required>YES<br>
                    <input type="radio" name="vision" id="vision" value="no" required>NO<br>
                    <input type="radio" name="vision" id="vision" value="Do not wish to reply" required> Do not wish to reply <br>

                <p class="question-header">Do you have any known history of a psychiatric or neurological condition?</p>
                    <input type="radio" name="neuro" id="neuro" value="yes" required>YES<br>
                    <input type="radio" name="neuro" id="neuro" value="no" required>NO<br>
                    <input type="radio" name="neuro" id="neuro" value="Do not wish to reply" required> Do not wish to reply <br>

                <br>

                <div class="flex flex-row" style="">
                    <a id="dyn-bttn" class="bttn b-right f6 link dim ph3 pv2 mb2 dib white bg-green" href="#0">Submit</a>
                </div>
            </div>
            </div>`


        document.querySelector("#main-display").style.visibility = "visible"
        document.querySelector("#dyn-bttn").setAttribute("onClick", "javascript: demographics.submit_response();")

    }
    let questions_radio = ["gender","race","color","vision","neuro"],
    questions_text = ["age","ethnicity"]


    submit_response = function () {

        complete = true;
        function validateRadioResponse(x) {
            for (i = 0; i <= x.length - 1; i++) {
                if (document.querySelector('input[name="' + x[i] + '"]:checked') === null) {
                    console.log("missing " + x[i])
                    complete = false
                }
            }
            return complete
        };
        validateRadioResponse(questions_radio)

        function validateTextResponse(x) {
            for (i = 0; i <= x.length - 1; i++) {
                if (document.querySelector('input[name="' + x[i] + '"]').value === ""){
                    console.log("missing " + x[i])
                    complete = false
                }
            }
            return complete
        };
        validateTextResponse(questions_text)

        
        if (complete == true) {
        q_array.push(new Data_row({
            time_start: stim_time,
            time_end: window.performance.now(),
            trial_type: "demographics",
            age: document.querySelector("#age").value,
            race: document.querySelector('input[name="race"]:checked') ? document.querySelector('input[name="race"]:checked').value: "no response",
            gender: document.querySelector('input[name="gender"]:checked') ? document.querySelector('input[name="gender"]:checked').value: "no response",
            ethnicity: document.querySelector("#ethnicity").value,
            color: document.querySelector('input[name="color"]:checked') ? document.querySelector('input[name="color"]:checked').value : "no response",
            vision: document.querySelector('input[name="vision"]:checked') ? document.querySelector('input[name="vision"]:checked').value : "no response",
            neuro: document.querySelector('input[name="neuro"]:checked') ? document.querySelector('input[name="neuro"]:checked').value : "no response",
        }))
        
        master.next()
        } else if (complete == false) {
            alert("Please make sure you have completed all the questions.")
        }
        
        
    }


    console.log("quest.js loaded")

    return {
        init: init,
        quest: quest,
        submit_response: submit_response,
        q_array: q_array
    }
}();
