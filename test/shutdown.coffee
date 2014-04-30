should = require 'should'

kue = require '../'

# jobs = kue.createQueue()
# Job = kue.Job
# jobs.promote 1

describe 'Kue', ->
  describe 'Shutdown', ->
    it 'should return singleton from createQueue', (done) ->
      jobs = kue.createQueue()
      jobsToo = kue.createQueue()

      jobs.should.equal jobsToo

      jobs.shutdown done

    it 'should destroy singleton on shutdown', (done) ->
      jobs = kue.createQueue()

      jobs.shutdown (err) ->

        # test that new jobs object is a different reference
        newJobs = kue.createQueue()
        newJobs.should.not.equal jobs

        newJobs.shutdown done

    it 'should clear properties on shutdown', (done) ->
      jobs = kue.createQueue()
      jobs.promote()
      jobs.shutdown (err) ->
        should(jobs.workers).be.empty
        should(jobs.client).be.empty
        should(jobs.promoter).be.empty
        done()

    it 'should be able to pause/resume the worker', (done) ->
      jobs = kue.createQueue()
      total_jobs = 3;
      job_data =
        title: 'resumable jobs'
        to: 'tj@learnboost.com'
      jobs.create('resumable-jobs', job_data).save()
      jobs.create('resumable-jobs', job_data).save()
      jobs.create('resumable-jobs', job_data).save()
      jobs.process 'resumable-jobs', 1, (job, job_done, ctx) ->
        if( !--total_jobs )
          done()
        else
          ctx.pause( ()->console.log "paused..." )
          setTimeout ( -> console.log "resuming..."; ctx.resume()), 2000
        job_done()