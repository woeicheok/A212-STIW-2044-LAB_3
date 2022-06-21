<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}
include_once("dbconnect.php");
$results_per_page = 5;
$pageno = (int)$_POST['pageno'];
$search = $_POST['search'];
$page_first_result = ($pageno - 1) * $results_per_page;

$sqlloadtutor = "SELECT * FROM tbl_tutors WHERE tutor_name LIKE '%$search%'";
$result = $conn->query($sqlloadtutor);
$number_of_result = $result->num_rows;
$number_of_page = ceil($number_of_result / $results_per_page);
$sqlloadtutor = $sqlloadtutor . "LIMIT $page_first_result , $results_per_page";
$result = $conn->query($sqlloadtutor);
 
if ($result-> num_rows > 0) {
    $tutor["tutor"] = array();
    while ($row = $result->fetch_assoc()) {
        $tutorlist = array();
        $tutorlist['tutor_id'] = $row['tutor_id'];
        $tutorlist['tutor_email'] = $row['tutor_email'];
        $tutorlist['tutor_phone'] = $row['tutor_phone'];
        $tutorlist['tutor_name'] = $row['tutor_name'];
        $tutorlist['tutor_password'] = $row['tutor_password'];
        $tutorlist['titor_description'] = $row['tutor_description'];
        $tutorlist['tutor_datereg'] = $row['tutor_datereg'];
        array_push($tutor["tutor"],$tutorlist);
    }
    $response = array('status' => 'success','pageno'=>"$pageno",'numofpage'=>"$number_of_page",  'data' => $tutor);
    sendJsonResponse($response);
}else{
    $response = array('status' => 'failed', 'pageno'=>"$pageno",'numofpage'=>"$number_of_page", 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>