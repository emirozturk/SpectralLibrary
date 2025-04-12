const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;
export default API_BASE_URL;

export async function getAll(route, id) {
  try{
    const url = id !== null ? `${API_BASE_URL}/${route}?id=${id}` : `${API_BASE_URL}/${route}`;
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });
    var resp = await response.json();
    if(resp.msg){
      return {
        isSuccess: false,
        message: resp.msg,
      };
    }
    return resp;
  } catch (e) {
    return {
      isSuccess: false,
      message: e.msg,
    };
  }
}
export async function getAllWithToken(route, id) {
  try {
    const url = id !== null ? `${API_BASE_URL}/${route}?id=${id}` : `${API_BASE_URL}/${route}`;
    var token = localStorage.getItem("token").replaceAll('"', "");
    const response = await fetch(url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",

        Authorization: `Bearer ${token}`,
      },
    });
    var resp = await response.json();
    if(resp.msg){
      return {
        isSuccess: false,
        message: resp.msg,
      };
    }
    return resp;
  } catch (e) {
    return {
      isSuccess: false,
      message: e.msg,
    };
  }
}

export async function post(route, object) {
  try {
    const response = await fetch(`${API_BASE_URL}/${route}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(object),
    });
    var resp = await response.json();
    if(resp.msg){
      return {
        isSuccess: false,
        message: resp.msg,
      };
    }
    return resp;
  } catch (e) {
    return {
      isSuccess: false,
      message: e.msg,
    };
  }
}

export async function postWithToken(route, object) {
  try {
    const response = await fetch(`${API_BASE_URL}/${route}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${localStorage.getItem("token").replaceAll('"', "")}`,
      },
      body: JSON.stringify(object),
    });
    var resp = await response.json();
    if(resp.msg){
      return {
        isSuccess: false,
        message: resp.msg,
      };
    }
    return resp;
  } catch (e) {
    return {
      isSuccess: false,
      message: e.msg,
    };
  }
}

export async function put(route, object) {
  try {
    const response = await fetch(`${API_BASE_URL}/${route}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(object),
    });
    var resp = await response.json();
    if(resp.msg){
      return {
        isSuccess: false,
        message: resp.msg,
      };
    }
    return resp;
  } catch (e) {
    return {
      isSuccess: false,
      message: e.msg,
    };
  }
}

export async function putWithToken(route, object) {
  try {
    const response = await fetch(`${API_BASE_URL}/${route}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${localStorage.getItem("token").replaceAll('"', "")}`,
      },
      body: JSON.stringify(object),
    });
    var resp = await response.json();
    if(resp.msg){
      return {
        isSuccess: false,
        message: resp.msg,
      };
    }
    return resp;
  } catch (e) {
    return {
      isSuccess: false,
      message: e.msg,
    };
  }
}

export async function delWithToken(route, id) {
  try {
    const response = await fetch(`${API_BASE_URL}/${route}/${id}`, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${localStorage.getItem("token").replaceAll('"', "")}`,
      },
    });
    var resp = await response.json();
    if(resp.msg){
      return {
        isSuccess: false,
        message: resp.msg,
      };
    }
    return resp;
  } catch (e) {
    return {
      isSuccess: false,
      message: e.msg,
    };
  }
}
