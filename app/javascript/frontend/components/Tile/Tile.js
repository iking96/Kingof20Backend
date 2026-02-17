import React, { useEffect, useState } from "react";
import { useDrag, useDrop } from "react-dnd";
import { determineValue } from "frontend/utils/tilePrintingHelper.js";

const Tile = ({
  value,
  is_starting = false,
  is_temp = false,
  inLastMove = false,
  canDrag = () => {},
  canDrop = () => {},
  didDrop = () => {},
  handleDrop = () => {}
}) => {
  const [{ isDragging }, drag] = useDrag({
    type: "tile",
    item: { value: value },
    collect: monitor => ({
      isDragging: !!monitor.isDragging()
    }),
    canDrag: () => canDrag(),
    end: (_, monitor) => monitor.didDrop() && didDrop()
  });

  const [{ isOver }, drop] = useDrop({
    accept: "tile",
    drop: (item) => handleDrop(item.value),
    collect: monitor => ({
      isOver: !!monitor.isOver()
    }),
    canDrop: () => canDrop()
  });

  return (
    <div className={"tile" + `${is_starting ? " starting" : ""}`} ref={drop}>
      {value == 0 ? (
        <>
          {!isOver ? <></> : <div className="highlight" />}
        </>
      ) : (
        <div className={"decal" + `${is_temp ? " temp" : ""}` + `${inLastMove ? " last-move" : ""}`} ref={drag}>
          {determineValue(value)}
        </div>
      )}
    </div>
  );
};

export default React.memo(Tile);
