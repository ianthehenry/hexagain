const S = function(tag, attrs) {
  const el = document.createElementNS('http://www.w3.org/2000/svg', tag);
  for (let key in attrs) {
    if (!Object.hasOwnProperty.call(attrs, key)) {
      continue;
    }
    const value = attrs[key];
    if (key === 'text') {
      el.appendChild(document.createTextNode(value));
    } else {
      el.setAttribute(key, value);
    }
  }
  return el;
}

const concat = (lists) => lists.flatMap((x) => x);
const stringifyPoints = (points) => points.map((a) => a.x + "," + a.y).join(' ');
const translateString = ({ x, y }) => 'translate(' + x + ', ' + y + ')';
const pointAdd = ({ x: x1, y: y1 }, { x: x2, y: y2 }) => { return { x: x1 + x2, y: y1 + y2 } };
const pointScale = ({ x, y }, s) => { return { x: x * s, y: y * s } };
const pointAverage = (a, b) => pointScale(pointAdd(a, b), 0.5);
const reversed = (list) => {
  const newList = list.slice(0);
  newList.reverse();
  return newList;
}

const radius = 0.5;
const apothem = Math.sqrt(3) * (radius / 2);
const spacing = apothem * Math.sqrt(3);

const coordinateAtCorner = function(corner, radius) {
  const angle = (corner + 0.5) * Math.PI * 2 / 6
  return {
    x: Math.cos(angle) * radius,
    y: Math.sin(angle) * radius
  }
}

const getCell = () => {
  const points = [0, 1, 2, 3, 4, 5].map((i) => coordinateAtCorner(i, radius * 0.7));
  return S('polygon', { points: stringifyPoints(points) })
};

const position = function(rank, file) {
  if (typeof rank === 'object') {
    file = rank.file;
    rank = rank.rank;
  }
  return {
    x: file * 2 * apothem + apothem * rank,
    y: spacing * rank
  };
};

const locationMapKey = ({ rank, file }) => rank.toString() + "-" + file.toString()

const displayOptions = { rotated: true, fullEdge: false, triangleEdges: true };

const getDecorations = function(size) {
  const units = [];
  for (let i = 0; i < size; i++) {
    units.push(i);
  }

  const leftEdge = units.flatMap((rank) => {
    const locus = position(rank, -1);
    return [
      pointAdd(locus, coordinateAtCorner(5, radius)),
      pointAdd(locus, coordinateAtCorner(0, radius))
    ];
  });
  const rightEdge = units.flatMap((rank) => {
    const locus = position(rank, size);
    return [
      pointAdd(locus, coordinateAtCorner(3, radius)),
      pointAdd(locus, coordinateAtCorner(2, radius))
    ];
  });
  const topEdge = units.flatMap((file) => {
    const locus = position(-1, file);
    return [
      pointAdd(locus, coordinateAtCorner(1, radius)),
      pointAdd(locus, coordinateAtCorner(0, radius))
    ];
  });
  const bottomEdge = units.flatMap((file) => {
    const locus = position(size, file);
    return [
      pointAdd(locus, coordinateAtCorner(3, radius)),
      pointAdd(locus, coordinateAtCorner(4, radius))
    ];
  });

  const border = concat([topEdge, rightEdge, reversed(bottomEdge), reversed(leftEdge)]);

  let lineCap;
  if (displayOptions.fullEdge) {
    const topRight = pointAverage(position(-1, size - 1), position(0, size));
    const bottomLeft = pointAverage(position(size - 1, -1), position(size, 0));
    rightEdge.unshift(topRight);
    topEdge.push(topRight);
    leftEdge.push(bottomLeft);
    bottomEdge.unshift(bottomLeft);
    lineCap = 'butt';
  } else {
    bottomEdge.pop();
    rightEdge.pop();
    leftEdge.shift();
    topEdge.shift();
    lineCap = 'round';
  }
  const topLeft = pointAdd(position(0, 0), coordinateAtCorner(4, radius));
  const topRight = pointAdd(position(0, size - 1), coordinateAtCorner(4, radius));
  const middle = position((size - 1) / 2, (size - 1) / 2);
  const rightTop = pointAdd(position(0, size - 1), coordinateAtCorner(5, radius));
  const rightBottom = pointAdd(position(size - 1, size - 1), coordinateAtCorner(5, radius));
  const leftTop = pointAdd(position(0, 0), coordinateAtCorner(2, radius));
  const leftBottom = pointAdd(position(size - 1, 0), coordinateAtCorner(2, radius));
  const bottomLeft = pointAdd(position(size - 1, 0), coordinateAtCorner(1, radius));
  const bottomRight = pointAdd(position(size - 1, size - 1), coordinateAtCorner(1, radius));

  return {
    border: S('polygon', { points: stringifyPoints(border), class: 'border' }),
    edgeFills: [
      S('polygon', { points: stringifyPoints([topLeft, topRight, middle]), class: 'edging black' }),
      S('polygon', { points: stringifyPoints([rightTop, rightBottom, middle]), class: 'edging white' }),
      S('polygon', { points: stringifyPoints([bottomLeft, bottomRight, middle]), class: 'edging black' }),
      S('polygon', { points: stringifyPoints([leftTop, leftBottom, middle]), class: 'edging white' })
    ],
    edgeStrokes: [
      S('polyline', { points: stringifyPoints(leftEdge), class: 'white', 'stroke-linecap': lineCap}),
      S('polyline', { points: stringifyPoints(rightEdge), class: 'white', 'stroke-linecap': lineCap }),
      S('polyline', { points: stringifyPoints(topEdge), class: 'black', 'stroke-linecap': lineCap }),
      S('polyline', { points: stringifyPoints(bottomEdge), class: 'black', 'stroke-linecap': lineCap })
    ]
  };
}

const renderBoard = function(state) {
  let size = state.size;
  let rotated = 'rotated' in state ? state.rotated : displayOptions.rotated;
  let annotations = state.annotations || [];
  let pieces = state.pieces || [];

  const svg = S('svg');
  const board = S('g', { class: 'board', transform: rotated ? 'rotate(-30)' : '' });
  const decorations = getDecorations(size);

  if (displayOptions.triangleEdges) {
    for (let el of decorations.edgeFills) {
      board.appendChild(el);
    }
    board.appendChild(decorations.border);
  } else {
    board.appendChild(decorations.border);
    for (let el of decorations.edgeStrokes) {
      board.appendChild(el);
    }
  }

  const colors = {};
  for (let { color, location } of pieces) {
    colors[locationMapKey(location)] = color;
  }

  for (let rank = 0; rank < size; rank++) {
    for (let file = 0; file < size; file++) {
      const colorClass = colors[locationMapKey({ rank, file })] || 'empty';
      const cell = S('g', { transform: translateString(position(rank, file)), class: 'cell ' + colorClass });
      board.append(cell);
      cell.append(getCell());
    }
  }

  for (let annotation of annotations) {
    switch (annotation[0]) {
      case 'bridge':
        const start = parseLocation(annotation[1]);
        const end = parseLocation(annotation[2]);
        const curveStart = position(start);
        const curveEnd = position(end);
        // todo: obviously
        const control1 = pointAverage(
          position({ rank: start.rank - 1, file: start.file + 2 }),
          position({ rank: start.rank, file: start.file + 1 })
          );
        const control2 = pointAverage(
          position({ rank: start.rank + 1, file: start.file }),
          position({ rank: start.rank + 2, file: start.file - 1 }),
        );
        board.append(S('path', {
          class: 'annotation',
          d: [
            'M', curveStart.x, curveStart.y,
            "Q", control1.x, control1.y, ",", curveEnd.x, curveEnd.y,
            "Q", control2.x, control2.y, ",", curveStart.x, curveStart.y
          ].join(' ')
        }));
      break;
      default: throw new Error("only bridges so far")
    }
  }

  let viewBox;
  if (rotated) {
    viewBox = [-radius, -apothem * size, spacing * ((size - 1) * 2) + 2 * radius, apothem * size * 2];
  } else {
    viewBox = [-apothem, -radius, apothem * 2 * (size * 1.5 - 0.5), spacing * (size - 1) + 2 * radius];
  }
  const padding = 0.1;
  viewBox[0] -= padding;
  viewBox[1] -= padding;
  viewBox[2] += 2 * padding;
  viewBox[3] += 2 * padding;

  svg.appendChild(board);
  svg.setAttribute('width', '100%');
  svg.setAttribute('height', size * 50);
  svg.setAttribute('viewBox', viewBox.map((i) => i.toString()).join(' '));
  svg.setAttribute('preserveAspectRatio', 'xMidYMid meet');
  return svg;
};

const parseLocation = function(location) {
  const rank = location[0].toLowerCase().charCodeAt(0) - 'a'.charCodeAt(0);
  const file = parseInt(location.substring(1), 10) - 1;
  return { rank, file };
}

const simpleGame = function({ size, initialTurn, moves }) {
  let players = ['black', 'white'];
  let pieces = moves.map((location, i) => {
    return { color: players[i % 2], location: parseLocation(location) };
  });
  let currentPieces = [];
  let states = pieces.map((newPiece) => {
    currentPieces = currentPieces.slice(0);
    currentPieces.push(newPiece);
    return { size: size, pieces: currentPieces };
  });
  states.unshift({ size: size, pieces: [] });
  return states.slice(initialTurn);
}

const parse = function(text) {
  let states = JSON.parse(text);
  if (!Array.isArray(states)) {
    if ('moves' in states) {
      return simpleGame(states);
    } else {
      states = [states];
    }
  }
  states.forEach((state) => {
    state.pieces = state.pieces.map(([color, location]) => {
      return { color: color, location: parseLocation(location) };
    });
  })
  return states;
}

const getPagingInterface = function(states) {
  const container = document.createElement('div');
  let currentPage = 0;
  let currentSvg = null;

  const pagingControls = document.createElement('div');
  const prevPageButton = document.createElement('button');
  const nextPageButton = document.createElement('button');
  const pageIndicator = document.createElement('span');

  const updatePage = function(page) {
    const newSvg = renderBoard(states[page]);
    if (currentSvg) {
      container.replaceChild(newSvg, currentSvg);
    } else {
      container.appendChild(newSvg, currentSvg);
    }
    pageIndicator.innerText = (currentPage + 1).toString() + " / " + states.length.toString();
    currentSvg = newSvg;
  }
  updatePage(0);

  pageIndicator.className = 'page-indicator';
  pagingControls.className = 'paging-controls';
  prevPageButton.className = 'prev-state';
  nextPageButton.className = 'next-state';
  prevPageButton.innerText = '←';
  nextPageButton.innerText = '→';
  prevPageButton.addEventListener('click', function() {
    currentPage = ((currentPage - 1) + states.length) % states.length;
    updatePage(currentPage);
  });
  nextPageButton.addEventListener('click', function() {
    currentPage = (currentPage + 1) % states.length;
    updatePage(currentPage);
  });
  pagingControls.appendChild(prevPageButton);
  pagingControls.appendChild(pageIndicator);
  pagingControls.appendChild(nextPageButton);
  container.appendChild(pagingControls);

  return container;
};

document.addEventListener("DOMContentLoaded", function() {
  // You can't modify an HTMLCollection that you're iterating over...
  const scripts = Array.prototype.slice.call(document.body.getElementsByTagName('script'));
  for (let script of scripts) {
    if (script.type === 'application/json') {
      const states = parse(script.text);
      if (states.length == 1) {
        script.parentElement.replaceChild(renderBoard(states[0]), script);
      } else {
        script.parentElement.replaceChild(getPagingInterface(states), script);
      }
    }
  }
});
