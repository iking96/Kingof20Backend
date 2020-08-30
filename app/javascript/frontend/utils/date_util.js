import React from "react";

function diff_minutes(dt2, dt1) {
  var diff = (dt2.getTime() - dt1.getTime()) / 1000;
  diff /= 60;
  return Math.abs(Math.round(diff));
}

function nth(d) {
  if (d > 3 && d < 21) return 'th';
  switch (d % 10) {
    case 1:  return "st";
    case 2:  return "nd";
    case 3:  return "rd";
    default: return "th";
  }
}

export function humanizedDate(comparisonTime) {
  var currentTime = new Date();
  var diff_mins = diff_minutes(currentTime, comparisonTime);
  if (diff_mins == 0) {
    return `Just Now`;
  }
  if (diff_mins == 1) {
    return `1 minute ago`;
  }
  if (diff_mins < 60) {
    return `${diff_mins} minutes ago`;
  }

  var diff_hours = diff_mins / 60;
  if (diff_hours == 1) {
    return `1 hour`;
  }
  if (diff_hours < 24) {
    return `${diff_hours} hours ago`;
  }

  var comparisonMonth = comparisonTime.toLocaleString('default', { month: 'long' });
  var comparisonDay = comparisonTime.getDate();
  return (
    <div>
      {comparisonMonth} {comparisonDay} <sup>{nth(comparisonDay)}</sup>
    </div>
  )
}
