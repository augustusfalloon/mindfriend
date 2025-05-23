const request = require('supertest');

const baseURL = 'http://localhost:3000'; // your running backend URL

describe('Basic route test', () => {
  it('POST for creating an account', async () => {
    const res = await request(baseURL)
      .post('/api/users/')
      .send({
        email: "test@gmail.com",
        username: "test1",
        password: "Password123!"
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.email).toBe("test@gmail.com");
    expect(res.body.username).toBe("test1");
  });
  it('Post for creating a friend account', async () => {
    const res = await request(baseURL)
      .post('/api/users/')
      .send({
        email: "friend@gmail.com",
        username: "friend1",
        password: "Password123!"
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.email).toBe("friend@gmail.com");
    expect(res.body.username).toBe("friend1");
  });
  it('Post for sending a friend request', async () => {
    const res = await request(baseURL)
        .post('/api/users/add-friend')
        .send({
            username: "test1",
            friendUsername: "friend1"
        });

    expect(res.statusCode).toBe(200);
  })
  it('Checking to see if the friend was added', async () => {
    const res = await request(baseURL)
        .get('/api/users/test1');

    expect(res.statusCode).toBe(200);
    expect(res.body.friends.length).toBe(1);
  });

  it('We will now ammend the facebook app to have a restriction of 60', async () => {
    const res = await request(baseURL)
        .patch('/api/users/update-restriction')
        .send({
            username: "test1",
            bundleID: "facebook",
            newTime: 60
        });
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toBe('Restriction updated successfully.');
  });

  it('now we will toggle facebook in order to make it exceeded', async() => {
    const res = await request(baseURL)
        .patch("/api/users/toggle-restriciton")
        .send({
            username: "test1",
            bundleID: 'facebook'
        });
    expect(res.statusCode).toBe(200);
  });

  it("we will check the ammendment by see if pass data about it, it will be exceeded by putting the time used as 70", async () => {
    const res = await request(baseURL)
        .post('/api/users/exceeded')
        .send( {
            username: "test1",
        });
    
    expect(res.statusCode).toBe(200);
    console.log(res.message);
    expect(res.body.length).toBe(1);
  })

  it("now we will test adding a comment to facebook since it should be exceeded", async() => {
    const res = await request(baseURL)
        .post("/api/users/add-comment")
        .send({
            username: "test1",
            comment: "This shoudl work",
            bundleID: "facebook"
        });
    expect(res.statusCode).toBe(200);
  });
});
