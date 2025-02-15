const API_BASE_URL = 'http://localhost:5000';

export async function getAll(route, id) {
  const url = id !== null ? `${API_BASE_URL}/${route}?id=${id}` : `${API_BASE_URL}/${route}`;
  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Content-Type': 'application/json',
    },
  });
  return await response.json();
}
export async function getAllWithToken(route, id) {
  try{
    const url = id !== null ? `${API_BASE_URL}/${route}?id=${id}` : `${API_BASE_URL}/${route}`;
    var token = localStorage.getItem('token').replaceAll('"', '')
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',

        Authorization: `Bearer ${token}`,
      },
    });
    return await response.json();
  }catch(e){
    console.log(e)
  }
}


export async function post(route, object) {
  const response = await fetch(`${API_BASE_URL}/${route}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(object),
  });
  return await response.json();
}

export async function postWithToken(route, object) {
  const response = await fetch(`${API_BASE_URL}/${route}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${localStorage.getItem('token').replace("\"", "")}`,
    },
    body: JSON.stringify(object),
  });
  return await response.json();
}

export async function put(route, object) {
  const response = await fetch(`${API_BASE_URL}/${route}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(object),
  });
  return await response.json();
}

export async function putWithToken(route, object) {
  const response = await fetch(`${API_BASE_URL}/${route}`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${localStorage.getItem('token').replace("\"", "")}`,
    },
    body: JSON.stringify(object),
  });
  return await response.json();
}

export async function delWithToken(route, id) {
  const response = await fetch(`${API_BASE_URL}/${route}/${id}`, {
    method: 'DELETE',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${localStorage.getItem('token').replace("\"", "")}`,
    },
  });
  return await response.json();
}
