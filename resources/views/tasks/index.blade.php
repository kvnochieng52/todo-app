@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">Tasks 8</div>

                <div class="card-body">
                    @if (session('success'))
                    <div class="alert alert-success">
                        {{ session('success') }}
                    </div>
                    @endif

                    <a href="{{ route('tasks.create') }}" class="btn btn-primary mb-3">Create New Task</a>

                    @if ($tasks->isEmpty())
                    <p>No tasks found.</p>
                    @else
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Title</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($tasks as $task)
                            <tr>
                                <td>{{ $task->title }}</td>
                                <td>
                                    <form action="{{ route('tasks.toggle-complete', $task) }}" method="POST">
                                        @csrf
                                        @method('PUT')
                                        <button type="submit"
                                            class="btn btn-sm {{ $task->completed ? 'btn-success' : 'btn-warning' }}">
                                            {{ $task->completed ? 'Completed' : 'Pending' }}
                                        </button>
                                    </form>
                                </td>
                                <td>
                                    <a href="{{ route('tasks.show', $task) }}" class="btn btn-info btn-sm">View</a>
                                    <a href="{{ route('tasks.edit', $task) }}" class="btn btn-primary btn-sm">Edit</a>
                                    <form action="{{ route('tasks.destroy', $task) }}" method="POST"
                                        style="display: inline;">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-danger btn-sm"
                                            onclick="return confirm('Are you sure?')">Delete</button>
                                    </form>
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
@endsection