/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
$( document ).ready(function() {
    
    $("#futurepay-existing").hide();
    $("#futurepay-new").hide();
    
    $("#create-fp").bind("click", function() {
        $("#futurepay-new").slideToggle(700);
        $("#futurepay-intro").slideToggle(700);
        
    });
    
    $("#activate-fp").bind("click", function() {
        $("#futurepay-existing").slideToggle(700);
        $("#futurepay-intro").slideToggle(700);

    });
    
    $("#create-fp-close").bind("click", function() {
        $("#futurepay-new").slideToggle(700);
        $("#futurepay-intro").slideToggle(700);

    });

    $("#activate-fp-close").bind("click", function() {
        $("#futurepay-existing").slideToggle(700);
        $("#futurepay-intro").slideToggle(700);

    });
    
});


