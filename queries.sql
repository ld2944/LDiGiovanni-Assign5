# 1. How many containers of antibiotics are currently available?

SELECT quantityOnHand
FROM item
WHERE itemDescription LIKE '%antibiotic%';

# 2. Which volunteer(s), if any, have phone numbers that do not start with the number 2 and whose last name is not Jones.

SELECT volunteerName, volunteerTelephone
FROM volunteer
WHERE volunteerTelephone NOT LIKE '2%' AND volunteerName NOT LIKE '%Jones';

# 3. Which volunteer(s) are working on transporting tasks?
# volunteer -> assignment -> task -> task_type

SELECT volunteer.volunteerName
FROM volunteer
JOIN assignment ON volunteer.volunteerId=assignment.volunteerId
JOIN task ON assignment.taskCode=task.taskCode
JOIN task_type ON task.taskTypeId=task_type.taskTypeId
WHERE taskTypeName LIKE 'transporting';

# Which task(s) have yet to be assigned to any volunteers (provide task descriptions, not the codes)?
SELECT task.taskDescription
FROM task
JOIN task_status ON task.taskStatusId=task_status.taskStatusId
WHERE task_status.taskStatusName LIKE 'pending';

#Which type(s) of package contain some kind of bottle?

SELECT DISTINCT package_type.packageTypeName
FROM package_type
JOIN package ON package.packageTypeId=package_type.packageTypeId
JOIN package_contents ON package.packageId=package_contents.packageId
JOIN item ON package_contents.itemId=item.itemId
WHERE item.itemDescription LIKE '%bottle%';

# Which items, if any, are not in any packages? Answer should be item descriptions.

SELECT item.itemDescription
FROM item
LEFT JOIN package_contents ON item.itemId=package_contents.itemId
WHERE package_contents.packageID IS NULL;

# Which task(s) are assigned to volunteer(s) that live in New Jersey (NJ)? Answer should have the
# task description and not the task ids.
# volunteer -> assignment -> task

SELECT task.taskDescription
FROM task
JOIN assignment ON task.taskCode=assignment.taskCode
JOIN volunteer ON assignment.volunteerId=volunteer.volunteerId
WHERE volunteer.volunteerAddress LIKE '%NJ%';

# Which volunteers began their assignments in the first half of 2021? 
# volunteer -> assignment

SELECT volunteer.volunteerName
FROM volunteer
JOIN assignment ON volunteer.volunteerId=assignment.volunteerId
WHERE assignment.startDateTime <='2021-07-02' AND assignment.startDateTime >'2021-01-01';

# Which volunteers have been assigned to tasks that include packing spam?
# volunteer -> assignment -> package -> package contents -> item

SELECT DISTINCT volunteer.volunteerName
FROM volunteer
JOIN assignment ON volunteer.volunteerId=assignment.volunteerId
JOIN package ON assignment.taskCode=package.taskCode
JOIN package_contents ON package.packageId=package_contents.packageId
JOIN item ON package_contents.itemId=item.itemId
WHERE item.itemDescription LIKE '%spam%';

# Which item(s) (if any) have a total value of exactly $100 in one package?
# item -> package_contents

SELECT item.itemDescription
FROM item
JOIN package_contents ON item.ItemId=package_contents.itemId
WHERE (item.itemValue * package_contents.itemQuantity)=100;

# How many volunteers are assigned to tasks with each different status? The answer should show
# each different status and the number of volunteers sorted from highest to lowest.
# volunteer, assignment, task, task_status use count

SELECT task_status.taskStatusName, COUNT(volunteer.volunteerName) AS volunteerCount
FROM task_status
JOIN task ON task_status.taskStatusId=task.taskStatusId
JOIN assignment ON task.taskCode=assignment.taskCode
JOIN volunteer ON assignment.volunteerId=volunteer.volunteerId
GROUP BY task_status.taskStatusName
ORDER BY volunteerCount DESC;

#Which task creates the heaviest set of packages and what is the weight? Show both the
#taskDescription and the weight (You should be able to do this without using any sub-queries).
# max

SELECT task.taskDescription, MAX(package.packageWeight) AS maxWeight
FROM task
JOIN package ON task.taskCode=package.taskCode
LIMIT 1;

#How many tasks are there that do not have a type of "packing"?
SELECT COUNT(taskDescription) AS taskCount
FROM task
WHERE taskDescription NOT LIKE '%packing%';

#Of those items that have been packed, which item (or items) were touched by fewer than 3
#volunteers? Answer should be item descriptions.
# volunteer, assignment, package, package_contents, item; count voluneers, where count >3

SELECT item.itemDescription, COUNT(itemQuantity) AS itemTouches
FROM item
JOIN package_contents ON item.itemId=package_contents.itemId
JOIN package ON package_contents.packageId=package.packageId
JOIN assignment ON package.taskCode=assignment.taskCode
JOIN volunteer ON assignment.volunteerId=volunteer.volunteerId
GROUP BY item.itemDescription
HAVING COUNT(itemQuantity) < 3

#Which packages have a total value of more than 100?
SELECT package_contents.packageId
FROM package_contents
JOIN item ON package_contents.itemId=item.itemId
GROUP BY packageId
HAVING SUM(item.itemValue * package_contents.itemQuantity) > 100;


