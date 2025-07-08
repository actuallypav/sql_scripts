/*
Outputs time (rounded up to nearest 5 minutes, GMT+1)

Includes both humidity and temperature

Applies a 5-unit outlier filter to both: excludes rows where either value jumps by more than 5 from the previous reading

Limits to 288 rows
Filters for thingname = e.g. 'Megatron'
*/
SELECT
  DATE_FORMAT(
    FROM_UNIXTIME(CEIL((t.`time` + 3600) / 300) * 300),
    '%H:%i'
  ) AS `time`,
  t.`temperature`,
  t.`humidity`
FROM (
  SELECT *,
         LAG(`temperature`) OVER (ORDER BY `time`) AS prev_temp,
         LAG(`humidity`) OVER (ORDER BY `time`) AS prev_humidity
  FROM `central_heating`
  WHERE `thingname` = 'Megatron'
) t
WHERE
  (t.`prev_temp` IS NULL OR ABS(t.`temperature` - t.`prev_temp`) <= 5)
  AND (t.`prev_humidity` IS NULL OR ABS(t.`humidity` - t.`prev_humidity`) <= 5)
ORDER BY
  t.`time` ASC
LIMIT 288;

/*
  This SQL query selects 1,152 rows from the `central_heating` table.
  - Device names are mapped to friendly room names (e.g., Megatron → Office).
  - Epoch time is converted to HH:MM format and adjusted by +1 hour (GMT+1).
  - The output includes ID, mapped device name, time, humidity, and temperature.
  - Results are ordered by time in ascending order.
*/

SELECT
  `central_heating`.`id` AS `id`,
  CASE
    WHEN `central_heating`.`thingname` = 'Megatron' THEN 'Office'
    WHEN `central_heating`.`thingname` = 'Scorponok' THEN 'Bedroom'
    WHEN `central_heating`.`thingname` = 'Shockwave' THEN 'Living Room'
    WHEN `central_heating`.`thingname` = 'Starscream' THEN 'Kitchen'
    ELSE `central_heating`.`thingname`
  END AS `thingname`,
  DATE_FORMAT(FROM_UNIXTIME(`central_heating`.`time` + 3600), '%H:%i') AS `time`,
  `central_heating`.`humidity` AS `humidity`,
  `central_heating`.`temperature` AS `temperature`
FROM
  `central_heating`
ORDER BY
  `central_heating`.`time` ASC
LIMIT
  1152;

